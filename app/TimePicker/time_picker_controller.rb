require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'time'

class TimePickerController < Rho::RhoController
  include BrowserHelper

  # タイムピッカートップページ
  def index
    render :back => '/app'
  end

  #タイムピッカー機能の呼び出し
  def choose
    #タイムピッカー機能の呼び出し・コールバックの設定
    DateTimePicker.choose(url_for(:action => :choose_callback),
                          #タイムピッカー画面のタイトルを指定
                          '選択して下さい',
                          #時間の初期値
                          Time.new,
                          #タイムピッカーの種類を指定
                          # 0  =>  日付・時間
                          # 1  =>  日付
                          # 2  =>  時間
                          @params['flg'].to_i,
                          #コールバックに渡す値をを設定
                          Marshal.dump(@params['flg'])
                         )
    redirect :action => :index
  end

  #タイムピッカーのコールバック(時間を選び終ると入る)
  def choose_callback
    if @params['status'] == 'ok'
      #resultに入っている文字列を時間に変換(ユーザーが選んだ時間・日付が取得できる)
      time = Time.at(@params['result'].to_i)
      #値をロードする
      flg = Marshal.load(@params['opaque'])
      #flgの値によって出力するフォーマットを指定する
      case flg
      when "0" then
        format = '%F %T'
      when "1"
        format = '%F'
      when "2"
        format = '%T'
      else
        format = '%F %T'
      end
      Alert.show_popup(
        :message => "#{time.strftime(format)}",
        :title => "あなたが選択した時間",
        :buttons => ["了解"]
      )
    end
    WebView.navigate(url_for(:action => :index))
  end

  #範囲指定のタイムピッカー
  def choose_range
    #範囲を指定してタイムピッカーを呼び出す
    DateTimePicker.choose_with_range(url_for(:action => :choose_callback),
                                     '選択して下さい',
                                     Time.new,
                                     @params['format'].to_i,
                                     Marshal.dump(@params['format']),
                                     #範囲を指定する最小値
                                     Time.now,
                                     #範囲を指定する最大値
                                     Time.now + 604800
                                     )
    redirect :action => :index
  end

  #Ajaxによるタイムピッカー機能
  def choose_ajax
    #Ajaxによるタイムピッカーのコールバックを指定(chooseメソッドの前に呼ぶ必要がある)
    DateTimePicker.set_change_value_callback(url_for(:action => :choose_ajax_callback))
    DateTimePicker.choose(url_for(:action => :choose_ajax_callback),
                          '選択して下さい',
                          Time.new,
                          0,
                          Marshal.dump("0")
                         )
  end

  #Ajaxによるタイムピッカー機能の呼び出し
  def choose_ajax_callback
    #パラメータ(@params['status'])
    #ユーザーが日付をリアルタイムに変更 => 'change'
    #ユーザーが日付を確定               => 'ok'
    #ユーザがキャンセルを押す           => 'cancel'

    case @params['status']
    when 'ok', 'change'
      time = Time.at(@params['result'].to_i)
      WebView.execute_js('SetTime("' + time.strftime('%F %T') + '");')
    when 'cancel'
      WebView.execute_js('SetTime("");')
    end
  end

end
