require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'

class SystemTestController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper

  # GET /SystemTest
  def index
    render :back => '/app'
  end

  # System.get_property('property')で取得できる値を一覧表示
  def properties
    @system = {}
    # * "platform"            :: プラットフォーム名
    # * "has_camera"          :: カメラの有無
    # * "screen_width"        :: 画面横幅(px)
    # * "screen_height"       :: 画面縦幅(px)
    # * "ppi_x"               :: 水平方向のPPI
    # * "ppi_y"               :: 垂直方向のPPI
    # * "has_network"         :: ネットワークの有無
    # * "phone_number"        :: 電話番号
    # * "device_id"           :: 端末ID
    # * "phone_id"            :: ハードウェアのID
    # * "full_browser"        :: フルブラウザ
    # * "device_name"         :: 端末名
    # * "os_version"          :: OSのバージョン
    # * "locale"              :: 設定されている言語
    # * "country"             :: 国名
    # * "is_emulator"         :: エミュレータか？
    # * "has_calendar"        :: カレンダー機能があるか？
    # * "is_motorola_device"  :: Motorolaのデバイスか？
    SystemTest::PROPERTIES.each do |property|
      @system[property] = System.get_property(property)
    end

    render :back => url_for(:action => :index)
  end

  # 画面の向きが変わったときを捕捉する
  def get_screen_rotation
    # System::set_screen_rotation_notification(callback_url, params)
    # ==== args
    # * callback_url :: 画面が回転したときに、呼び出すコールバック先のURL
    # * params       :: コールバック先へ渡すパラメータを指定する。
    System::set_screen_rotation_notification(url_for(:action => :get_screen_rotation_callback), "")
    render :action => :index
  end

  # 画面の向きの捕捉を解除
  def unset_screen_rotation
    System::set_screen_rotation_notification(nil, nil)
    render :action => :index
  end

  # 画面の向きが変わったときに呼ばれるコールバック
  def get_screen_rotation_callback
    puts "ROTATION!!!!!!"
    Alert.show_popup("画面の向きがかわりました。")
  end

  # アプリケーションを終了させる前に
  # 確認のアラートをだす。
  def app_exit
    Alert.show_popup(
      :title => "確認",
      :icon => :alert,
      :message => "本当に終了しますか？",
      :buttons => ["OK", {:id => "cancel", :title => "キャンセル"}],
      :callback => url_for(:action => :app_exit_callback)
    )
    render :action => :index
  end

  # アプリケーションを終了される処理を行う。
  def app_exit_callback
    if @params["button_id"] == "cancel"
      WebView.navigate(url_for(:action => :index))
    else
      System.exit
    end
  end

  # 端末をスリープさせる。
  def sleeping
    $sleeping = !$sleeping
    System.set_sleeping($sleeping)
    render :action => :index
  end

  # URLからリンク先を開く
  def open_url
    System.open_url("http://www.kouboum.co.jp")
    render :action => :index
  end

  # 他のアプリケーションを起動する。
  def run_app
    # System.run_app(appname, params)
    # * appname :: 起動したいアプリケーション名
    # * params  :: アプリケーションに渡すパラメータ
    case platform
    when "android"
      System.run_app('market', "")
    when "apple"
      System.run_app('store', "security_token=123")
    end
    render :action => :index
  end

  # アプリケーションをインストールする。
  def app_install
    # System.app_install(url)
    # * url :: インストールしたいアプリのURL
    case platform
    when "android"
      url = 'https://rhohub-prod-ota.s3.amazonaws.com/129b1fd5930d4d40b906addd08d61058/simpleapp-rhodes_signed.apk'
      System.app_install(url)
    when "apple"

    end
    render :action => :index
  end

  # アプリケーションがインストールされているかを判定
  def app_installed
    # System.app_installed?(appname)
    # * appname :: インストールされているか判定するアプリ名
    case platform
    when "android"
      if System::app_installed?("com.android.music")
        msg = "musicがインストールされています。"
      else
        msg = "musicがインストールされていません。"
      end
    when "apple"
      if System::app_installed?("skype")
        msg = "skypeがインストールされています。"
      else
        msg = "skypeがインストールされていません。"
      end
    end
    
    Alert.show_popup(msg)
    render :action => :index
  end

  # アプリケーションのアンインストール
  # Androidのみ正しい挙動をする。
  def app_uninstall
    System.app_uninstall("com.android.music")
    render :action => :index
  end

  # ZIPファイルを展開する。
  def unzip
    model_path = Rho::RhoApplication.get_model_path("app", "SystemTest")
    url = model_path + "sample.zip"
    System::unzip_file(url)
    sleep(1)
    if File.exists?(model_path + "sample.txt")
      Alert.show_popup("ZIPファイルの解凍に成功しました。")
      File.unlink(model_path + "sample.txt")
    end
    render :action => :index
  end

  # iOSのみ
  def get_start_params
    Alert.show_popup(System::get_start_params)
    render :action => :index
  end

  # 本アプリにbadgeを追加する。
  # iOSのみ
  def add_badge
    System.set_application_icon_badge(3)
    render :action => :index
  end

  # badgeを削除する。
  # iOSのみ
  def remove_badge
    System.set_application_icon_badge(0)
    render :action => :index
  end
end
