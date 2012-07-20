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
    Rho::Timer.start(5000, url_for(:action => :timer_callback), 'test')
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
    WebView.navigate(url_for(:action => :index))
  end
end
