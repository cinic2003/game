# incoding: utf-8
require 'spader'
require 'rubygems'

# 网页游戏 http://web.7k7k.com/xxxxx
# 专题游戏 http://news.7k7k.com/xxxx
# 直接flash游戏:
# /special/xxxx 直接进入游戏页面
# /flash/xxxx.html 通过该页面到游戏页面 /swf/xxxx
# 


class Qkqk < Spader
  
  module QKQK
    WEB = 'http://www.7k7k.com/'
    CATEGORY_NUM = 1..500
  end

  def find_url
    links = @page.css(".bp ul li h4 a") + @page.css(".c ul li h4 a")
    links.each do |link|
      game_url = link.attributes['href'].value
      game_name = link.children[0].text
      if game_url.start_with?('flash/')
        puts game_name
        puts game_url
        puts '页面跳转-----------------------'
      elsif game_url.start_with?('/special/')
        puts game_name
        puts game_url
        puts '直接下载-----------------------'
      else
        puts game_url
        puts '网页或专题'
      end
    end

    puts @url
    puts links.size
  end
  

end


if __FILE__ == $0
  require "#{File.dirname(__FILE__)}/../config/environment"
  url = 'http://www.7k7k.com'
  Qkqk.new(url).find_url#.each {|url| p find_swf(url)}

end
