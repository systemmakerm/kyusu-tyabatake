require 'rho/rhocontroller'
require 'helpers/browser_helper'

# 着信音機能
class RingtonesController < Rho::RhoController
  include BrowserHelper

  # 着信音一覧
  def index
    #   Rho::RingtoneManager::stop
    # 着信音を再生中の場合、停止する。
    Rho::RingtoneManager::stop
    
    #   Rho::RingtoneManager::get_all_ringtones
    # 端末に保存されている着信音をすべて取得
    @ringtones = Rho::RingtoneManager::get_all_ringtones
    @ringtones = [] if @ringtones.nil?
    render :back => Rho::RhoConfig.start_path
  end

  # 着信音を再生する。
  def play_ringtone
    @name = @params["name"]
    #   Rho::RingtoneManager::play(file_path)
    # 引数で指定したファイルパスの着信音を再生する。
    # ==== args
    # * file_path:: ファイルパス
    Rho::RingtoneManager::play(@params["file"])
    render :back => url_for(:action => :index)
  end
  
  # 着信音を再生する。
  def ajax_start_ringtone
    #   Rho::RingtoneManager::play(file_path)
    # 引数で指定したファイルパスの着信音を再生する。
    # ==== args
    # * file_path:: ファイルパス
    Rho::RingtoneManager::play(@params["file"])
    render :string => ""
  end
  
  # 着信音の再生を停止する。
  def ajax_stop_ringtone
    #   Rho::RingtoneManager::stop
    # 着信音を再生中の場合、停止する。
    Rho::RingtoneManager::stop
    render :string => ""
  end
  
  
end
