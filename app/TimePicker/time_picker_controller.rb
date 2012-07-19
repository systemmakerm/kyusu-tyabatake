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
    DateTimePicker.choose(url_for(:action => :choose_callback),
                          '選択して下さい',
                          Time.new,
                          @params['flg'].to_i,
                          Marshal.dump(@params['flg'])
                         )
    redirect :action => :index
  end

  def choose_callback
    if @params['status'] == 'ok'
      time = Time.at(@params['result'].to_i)
      flg = Marshal.load(@params['opaque'])
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
        #表示するメッセージを指定
        :message => "#{time.strftime(format)}",
        #ポップアップのタイトルを指定
        :title => "あなたが選択した時間",
        :buttons => ["了解"]
      )
    end
    WebView.navigate(url_for(:action => :index))
  end

  def choose_range
    DateTimePicker.choose_with_range(url_for(:action => :choose_callback),
                                     '選択して下さい',
                                     Time.new,
                                     @params['format'].to_i,
                                     Marshal.dump(@params['format']),
                                     Time.now,
                                     Time.now + 31536000
                                     )
    redirect :action => :index
  end


end
