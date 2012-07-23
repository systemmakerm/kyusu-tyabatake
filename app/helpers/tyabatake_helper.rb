# Tyabatakeで使用するヘルパー
module TyabatakeHelper
  #   hbr(str) -> String
  # HTMLタグをエスケープして、改行コードを<br />に変換する。
  # ==== args
  # * s - エスケープしたい文字列 
  def hbr(str)
    h(str).gsub(/\r\n|\r|\n/, "<br />")
  end
  
  HTML_ESCAPE = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;' }
  #   html_escape(str) -> String
  # HTMLタグをエスケープして表示する。
  # ==== args
  # * s - エスケープしたい文字列 
  def html_escape(s)
    s = s.to_s
    s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
  end
  alias :h html_escape
end
