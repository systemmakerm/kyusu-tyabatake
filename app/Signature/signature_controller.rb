require 'rho/rhocontroller'
require 'helpers/browser_helper'

class SignatureController < Rho::RhoController
  include BrowserHelper
  layout 'Signature/layout'


  #サイン機能トップページ
  def index
    #サイン領域を見えなくする
    Rho::SignatureCapture.visible(false, nil)
    @signatures = Signature.find(:all)
    render :back => '/app'
  end

  #全画面サイン機能
  def take_signature
    #サイン画面を起動                  コールバックの設定(確定ボタンを押すと入る)
    Rho::SignatureCapture.take(url_for(:action => :signature_callback),
                               #サイン画像のフォーマット
                              {:imageFormat => "jpg",
                               #線の色
                               :penColor    => 0xff0000,
                               #線の幅
                               :penWidth    => 5,
                               #ボーダーがあるかないか
                               :border      => true,
                               #背景色
                               :bgColor     => 0x00ff00
                              }
                              )
    redirect :action => :index
  end

  #インラインサイン機能
  def take_signature_inline
    #インラインでサインを書く領域を描画(コントローラーから直接描画しているので、指定された位置に、ビューの上から描画する)
    Rho::SignatureCapture.visible(true,
                                  :penColor  => 0xFFFF0000,
                                  :penWidth  => 5,
                                  :border    => true,
                                  :bgColor   => 0x4F00ff00,
                                  #左から何ピクセル目に描画するか
                                  :left      => @params['left'],
                                  #上から何ピクセル目に描画するか
                                  :top       => @params['top'],
                                  #描画するサイズの横幅
                                  :width     => @params['width'],
                                  #描画するサイズの縦幅
                                  :height    => @params['height']
                                 )
    render :back => url_for(:action => :index)
  end

  #全画面でのサインが確定、あるいは、インラインサインでキャプチャしたら入る
  def signature_callback
    #正常にキャプチャが終了したか
    if @params['status'] == 'ok'
      #DBに画像のuriを保存
      Signature.create({:signature_uri => @params['signature_uri']})
    end
   WebView.navigate(url_for(:action => :index))
  end

  #キャプチャ機能
  def capture
    #現在のサインをキャプチャする(インライン時に使用)
    Rho::SignatureCapture.capture(url_for(:action => :signature_callback))
  end

  #クリア機能
  def clear
    #現在書いているサインをクリアする
    Rho::SignatureCapture.clear
  end
end
