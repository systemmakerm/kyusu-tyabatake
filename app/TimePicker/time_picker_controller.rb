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
    DateTimePicker.choose(url_for(:action => :choose_callback), '時間を選択して下さい', Time.new, @params['flg'].to_i,  Marshal.dump(@params['flg']))
  end

  def choose_callback
    if @params['status'] == 'ok'
      Alert.show_popup(
        #表示するメッセージを指定
        :message => "#{@params['result']}",
        #ポップアップのタイトルを指定
        :title => "お知らせ",
        :buttons => ["了解"]
      )
    end
    WebView.navigate(url_for(:action => :index))
  end
end
