require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'json'

# JSON機能
class JsonTestController < Rho::RhoController
  include BrowserHelper

  # JSON機能トップメニュー
  def index
    render :back => Rho::RhoConfig.start_path
  end
  
  # JSONファイルを解析して表示する。
  def parse_json
    json_path = File.join(Rho::RhoApplication.get_model_path("app", "JsonTest"), "sample.json")
    file = File.new(json_path)
    @json = file.read
    #   Rho::JSON.parse(str)
    # 引数で渡した文字列をJSON解析する。
    # ==== args
    # * str :: JSON解析を行いたい文字列
    @parse_json = Rho::JSON.parse(@json)
    render :back => url_for(:action => :index)
  end
  
  # JSONファイルをサーバから取得して、表示する。
  def get_json
    lat = 35.45966680
    lon = 133.07849220
    # Google Map Apiにアクセスし、軽度、緯度情報から住所をJSON形式で取得
    http = Rho::AsyncHttp.get(
      # アクセス時にヘッダ情報を日本語にする。
      :headers => {"Accept-Language" => "ja"},
      :url => "http://maps.google.com/maps/api/geocode/json?latlng=#{lat},#{lon}&sensor=false"
    )
    if http["status"] == "ok"
      # HTTPのbodyには、JSON解析されたHashの値が入る。
      body = http["body"]
      @address = body["results"].first["formatted_address"]
      render :back => url_for(:action => :index)
    else
      Alert.show_popup("データが取得できませんでした。")
      redirect :action => :index
    end
  end
  
  # JSONファイルを生成する。
  def generate_json
#    json_path = File.join(Rho::RhoApplication.get_model_path("app", "JsonTest"), "generate.json")
    json_path = File.join(Rho::RhoApplication.get_blob_path("generate.json"))
    if File.exists?(json_path)
      File.unlink(json_path)
    end
    
    @value = {:project => {:title => "Ruby on SmartPhone with PaaS"}}
    
    File.open(json_path, "w") do |f|
      #   ::JSON.generate(value)
      # 引数で渡した値をJSON形式の文字列に変換する。
      # ==== args
      # * value :: JSON化したい値
      f.print ::JSON.generate(@value)
    end
    
    @json = File.new(json_path).read
    render :back => url_for(:action => :index)
  end

end
