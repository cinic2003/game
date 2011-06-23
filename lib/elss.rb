# encoding: utf-8
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

class Elss
  
  module URL2144
    URL = 'http://www.2144.cn'
    CATEGORY = 'http://www.2144.cn/html/'
    CATEGORY_NUM = 120..200
    DOWNLOAD = 'http://www.2144.cn/down.php?id='
  end
  
  def find_swf
    for i in URL2144::CATEGORY_NUM
      category_url = URL2144::CATEGORY + i.to_s
      puts category_url

      begin
        page = Nokogiri::HTML(open(category_url), nil, 'gb2312')
        links = page.css(".only_list li a")
        puts links.size
        links.each do |link|
          if link.attributes['href'].value.start_with?('/html')
            game_url = link.attributes['href'].value
            swf_id = game_url.split('/').last
            name = link.text
            
<<<<<<< HEAD
            # 忽略已保存过的游戏，判断分类-ID
            next if Swf.find_by_category_id("#{i}-#{swf_id}")
            # 忽略游戏链接格式不是 /html/xx/xxxx 的游戏链接
            unless game_url.start_with?('/html/')
              puts game_url
              puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
              next
            end
            name = link.children[0].text
          
            # 进入该游戏下载页面，如果可以下载则直接下载，否则进入该游戏页面，在该页面分析js中的flash的url
            download = Nokogiri::HTML(open(down + swf_id))
            unless download.css(".downlinks").empty?
              # 通过下载链接获取swf的url
              swf_url = download.css(".downlinks")[0].attributes['href'].value
            else
              #如果不能下载，则返回游戏页面，分析js获得swf的url
              game_url = 'http://www.2144.cn' + game_url
              page = Nokogiri::HTML(open game_url)
              js = page.search('script').detect {|j| j.children[0].to_s.include?('game_filename')}
              # 从js中查找game_filename中的url
              unless js.to_s.scan(/game_filename=\'(.*(swf|htm))/).empty?
                end_url = $1 #js.to_s.scan(/game_filename=\'(.*(swf|htm))/)[0][0]
              else
                puts "No find swf url in javascript"
                puts "=================================="
                next
              end

              # 如果是以htm结尾，还需到该htm页面去爬flash，先忽略
              next if end_url.end_with?('htm')

              swf_url = end_url.start_with?('http') ? end_url : "http://flash.2144.cn/qigongzhu/#{end_url}"
=======
            download_url = URL2144::DOWNLOAD + swf_id
            begin
              page = Nokogiri::HTML(open(download_url), nil, 'gb2312')
              swf_url = page.css(".downlinks").empty? ? page.css(".downlinks")[0].attributes['href'].value : "#{URL2144::URL}#{game_url}"
            rescue OpenURI::HTTPError
              puts "Network error, next"
>>>>>>> 59bf033... add app
            end
          else
            puts "Not download link: #{link} "
          end
          
          puts name
          puts swf_url
          puts '------------------------------------'
        end        
      rescue OpenURI::HTTPError
        puts "Not find URL: #{category_url}"
      end
    end
  end
  
end

if __FILE__ == $0
  # require "#{File.dirname(__FILE__)}/../config/environment"
  Elss.new.find_swf
end
