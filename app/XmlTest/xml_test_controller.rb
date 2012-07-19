require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'
require 'rexml/document'

# XML機能
class XmlTestController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper

  
  # XML機能トップメニュー
  def index
    render :back => Rho::RhoConfig.start_path
  end
  
  # XMLの解析処理
  def parse_xml
    file_name = File.join(Rho::RhoApplication::get_model_path('app','XmlTest'), 'sample.xml')
    file = File.new(file_name)
    @xml = REXML::Document.new(file)
    render :back => url_for(:action => :index)
  end
  
  # RSSを解析して表示する。
  def show_rss
    http = Rho::AsyncHttp.get(:url => "http://rss.dailynews.yahoo.co.jp/fc/sports/rss.xml")
    if http["status"] == "ok"
      # HTTPアクセス成功時
      @xml = REXML::Document.new(http["body"])
    else
      # HTTPアクセス失敗時
      Alert.show_popup("サーバからRSSを取得できませんでした。")
      redirect :action => :index
    end
  end
end
