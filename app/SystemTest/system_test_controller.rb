require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'

class SystemTestController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper

  # System機能トップ
  def index
    render :back => '/app'
  end

  # System::get_property('property')で取得できる値を一覧表示
  def properties
    @system = {}
    #   System::get_property(property_name)
    # 引数で指定したプロパティの値を取得する。
    # ==== args
    # * property_name                :: 取得するプロパティ名
    # * <tt>platform</tt>            :: プラットフォーム名
    # * <tt>has_camera</tt>          :: カメラの有無
    # * <tt>screen_width</tt>        :: 画面横幅(px)
    # * <tt>screen_height</tt>       :: 画面縦幅(px)
    # * <tt>ppi_x</tt>               :: 水平方向のPPI
    # * <tt>ppi_y</tt>               :: 垂直方向のPPI
    # * <tt>has_network</tt>         :: ネットワークの有無
    # * <tt>phone_number</tt>        :: 電話番号
    # * <tt>device_id</tt>           :: 端末ID
    # * <tt>phone_id</tt>            :: ハードウェアのID
    # * <tt>full_browser</tt>        :: フルブラウザ
    # * <tt>device_name</tt>         :: 端末名
    # * <tt>os_version</tt>          :: OSのバージョン
    # * <tt>locale</tt>              :: 設定されている言語
    # * <tt>country</tt>             :: 国名
    # * <tt>is_emulator</tt>         :: エミュレータか？
    # * <tt>has_calendar</tt>        :: カレンダー機能があるか？
    # * <tt>is_motorola_device</tt>  :: Motorolaのデバイスか？
    SystemTest::PROPERTIES.each do |property|
      @system[property] = System::get_property(property)
    end

    render :back => url_for(:action => :index)
  end

  # 画面の向きが変わったときを捕捉する
  def get_screen_rotation
    #   System::set_screen_rotation_notification(callback_url, params)
    # 画面の向きが変わったことを捕捉する。
    # callback_url, paramsに nil を指定すると、捕捉を解除することができる。
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
    Alert.show_popup("画面の向きが変わりました。")
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

  # アプリケーションの終了
  def app_exit_callback
    if @params["button_id"] == "cancel"
      WebView.navigate(url_for(:action => :index))
    else
      #   System::exit
      # アプリの終了処理
      System::exit
    end
  end

  # 端末のスリープモードを有効化/無効化
  def sleeping
    $sleeping = !$sleeping
    #   System::set_sleeping(flg)
    # 端末のスリープモードを有効化/無効化を行う。
    # ==== args
    # * flg             :: true or false
    # * <tt>true</tt>   :: スリープを有効化
    # * <tt>false</tt>  :: スリープを無効化
    System::set_sleeping($sleeping)
    render :action => :index
  end

  # URLからリンク先を開く
  def open_url
    #   System::open_url(url)
    # 引数で渡したURLを開く
    # ==== args
    # * url :: 開くURLを指定
    System::open_url("http://www.kouboum.co.jp")
    render :action => :index
  end

  # 他のアプリケーションを起動する。
  def run_app
    #   System::run_app(appname, params)
    # 引数で渡したアプリケーションを起動する。
    # ==== args
    # * appname :: 起動したいアプリケーション名
    # * params  :: アプリケーションに渡すパラメータ
    case platform
    when "android"
      System::run_app('market', "")
    when "apple"
      System::run_app('skype://', "")
    end
    render :action => :index
  end

  # アプリケーションをインストールする。
  def app_install
    #   System::app_install(url)
    # 引数で指定したアプリケーションをインストールする。
    # ==== args
    # * url :: インストールしたいアプリのURL
    url = 'https://rhohub-prod-ota.s3.amazonaws.com/129b1fd5930d4d40b906addd08d61058/simpleapp-rhodes_signed.apk'
    System::app_install(url)
    render :action => :index
  end

  # アプリケーションがインストールされているかを判定
  def app_installed
    #   System::app_installed?(appname)
    # 引数で指定したアプリケーションがインストールされているかを判定して返す。
    # ==== args
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
    #   System::app_uninstall(appname)
    # 引数で指定したアプリケーションをアンインストールする。
    # ==== args
    # * appname :: アプリケーション名
    System::app_uninstall("com.android.music")
    render :action => :index
  end

  # ZIPファイルを解凍する。
  def unzip
    model_path = Rho::RhoApplication.get_model_path("app", "SystemTest")
    url = model_path + "sample.zip"
    #   System::unzip_file(url)
    # 引数で指定したパスにあるZipファイルを解凍する。
    # ==== args
    # * url :: 解凍したいZIPファイルのパス
    System::unzip_file(url)
    sleep(1)
    if File.exists?(model_path + "sample.txt")
      Alert.show_popup("ZIPファイルの解凍に成功しました。")
      File.unlink(model_path + "sample.txt")
    end
    render :action => :index
  end

  # 本アプリにbadgeを追加する。
  # iOSのみ
  def add_badge
    #   System::set_application_icon_badge(num)
    # 引数で渡した値のバッジをアプリケーションアイコンに設定できる。
    # iOS系のみ使用することができる。
    # ==== args
    # * num :: 設定するバッジの値。0を渡すとバッジが消える。
    System::set_application_icon_badge(3)
    render :action => :index
  end

  # badgeを削除する。
  # iOSのみ
  def remove_badge
    System::set_application_icon_badge(0)
    render :action => :index
  end
end
