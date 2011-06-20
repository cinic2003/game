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
      begin
        if game_url.start_with?('flash/')
          puts game_name
          # 直接从页面中的js中获取下载地址
          download_url_from_js(QKQK::WEB + game_url)

        elsif game_url.start_with?('/special/')
          puts game_name
          puts game_url
          puts '直接下载-----------------------'
        else
          puts game_url
          puts '网页或专题'
          links = get_game_url_from_special(game_url)
          links.each do |link|
            get_game_url_from_special(link).each  do |url|
              name = url[0]
              download_url = download_url_from_js(url[1])
              puts name
              puts download_url
            end
          end
        end
      rescue Errno::ECONNREFUSED
        puts 'Connection REFUSED'
      end
    end

    puts @url
    puts links.size
  end
  
  def download_url_from_js(url)
    game_page = Nokogiri::HTML(open url)
    js = game_page.search('script').detect {|j| j.children[0].to_s.include?('_gamepath')}
    unless js.to_s.scan(/_gamepath\s=\s\"(.*\.(swf|html))/).empty?
      if $2 == 'swf'
        download_url = $1
        puts download_url
        download_url  
      end
    end
  end

  def get_game_url_from_special(url)
    # 通过某一专题页面 查找该页面中的游戏链接
    page = Nokogiri::HTML(open url)
    urls = []
    links = page.css('.plH1 li span a')
    # 将每个游戏对应的名称和其url组成一个数组，在将所有这样的数组放在一个大数组中
    links.each do |link|
      urls << [link.children[0].text, link.attributes['href'].value]
    end
    urls
  end

end


if __FILE__ == $0
  require "#{File.dirname(__FILE__)}/../config/environment"
  url = 'http://www.7k7k.com'
  #Qkqk.new(url).find_url#.each {|url| p find_swf(url)}
  qkqk = Qkqk.new(url)
  urls = qkqk.get_game_url_from_special('http://news.7k7k.com/lanqiu/lanqiuzt/')
  urls.each do |url|
    puts url[0]
    qkqk.download_url_from_js(url[1])
  end
end
