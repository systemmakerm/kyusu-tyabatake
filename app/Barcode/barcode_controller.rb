require 'rho/rhocontroller'
require 'helpers/browser_helper'

class BarcodeController < Rho::RhoController
  include BrowserHelper

  # GET /Barcode
  def index
    puts Barcode.methods
    render :back => '/app'
  end

  #バーコード読み取り機能
  def take_barcode
    #バーコードを読み取る(コールバックを指定)
    Barcode.take_barcode(url_for(:action => :barcode_callback), {})
    redirect :action => :index
  end

  #画像からバーコードの読み取り
  def image_scan
    #画像からバーコードを読み取る(画像イメージのフルパス)
    result = Barcode.barcode_recognize(File.join(Rho::RhoApplication::get_model_path('app','Barcode'), 'QRcode.gif'))
    Alert.show_popup(result)
    redirect :action => :index
  end

  #コールバック
  def barcode_callback
    if @params['status'] == 'ok'
      #読み取ったバーコードをポップアップで表示
      Alert.show_popup(@params['barcode'])
    end
    #コールバックが終了したら画面を移動
    WebView.navigate(url_for(:action => :index))
  end

  def enumerate
    Barcode.enumerate(url_for(:action => :enumerate_callback))
    redirect :action => :index
  end

  def enumerate_callback
    Alert.show_popup(@params.inspect)
    WebView.navigate(url_for(:action => :index))
  end
end
