require 'rho/rhocontroller'
require 'helpers/browser_helper'

class HttpConnectController < Rho::RhoController
  include BrowserHelper

  # GET /HttpConnect
  def index
    render :back => '/app'
  end

  def get_access
    Rho::AsyncHttp.get(
      :url             => 'http://192.168.1.208:3000/asyncs.json',
      :headers         =>  {"Cookie" => "cookieなどを送る時に使用する"},
      :callback        =>  (url_for(:action => :http_callback)),
      :callback_param  =>  "test=test",
      :authentication  => {
                            :type       =>  :basic,
                            :username  =>  "systemmakerm",
                            :password  =>  "systemmakerm"
                          },
      :ssl_verify_peer =>  true
    )
    render :string => "接続中....."
  end

  def post_access
    Rho::AsyncHttp.post(
      :url             => 'http://192.168.1.208:3000/asyncs.json',
      :body            => "username=systemmakerm&password=systemmakerm",
      :callback        => (url_for(:action => :http_callback))
      #違うメソッでのアクセスも出来る(例：PUT)
      #:http_command    => "put"
    )
    render :string => "接続中....."
  end

  def download
    Rho::AsyncHttp.download_file(
      :url => 'http://192.168.1.208:3000/robots.txt',
      :filename => File.join(Rho::RhoApplication::get_base_app_path(),  'test.txt'),
      :headers => {},
      :callback => (url_for :action => :http_callback),
      :callback_param => ""
    )
    render :string => "ダウンロード中"
  end

  def http_callback
    if @params['status'] == 'ok'
      msg = "通信に成功しました"
    else
      msg = "通信に失敗しました"
    end
    WebView.navigate(url_for(:action => :index))
  end
end
