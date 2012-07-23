require 'rho/rhocontroller'
require 'helpers/browser_helper'

class RhotimerController < Rho::RhoController
  include BrowserHelper

  #タイマー機能トップページ
  def index
    render :back => '/app'
  end

  #タイマーをスタートさせる
  def timer_start
    #タイマー機能スタート(時間(ミリ), コールバックURL, コールバックへ渡す値)
    Rho::Timer.start(5000, url_for(:action => :timer_callback), "type=#{@params['type']}")
    case @params['type']
    when "1"
      @msg = "5秒後に元の画面へ戻ります。"
    when "2"
      @msg = "5秒後にポップアップが表示されます。"
    end
    render :action => :wait
  end

  #タイマーをストップさせる
  def timer_stop
    #タイマーをストップ(コールバックURL)
    Rho::Timer.stop(url_for(:action => :timer_callback))
    redirect :action => :index
  end

  #タイマーのコールバック
  def timer_callback
    if @params['type'] == "2"
      Alert.show_popup(
        :message => "5秒経過しました",
        :title => "お知らせ",
        :buttons => ["同意"],
      )
    end
    WebView.navigate(url_for(:action => :index))
  end
end
