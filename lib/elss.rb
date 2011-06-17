# encoding: utf-8
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'


# 1.前段都为http://www.2144.cn/html/xx/xxxxxxx/

class Elss
  
  module URL2144
    WEB = 'http://www.2144.cn/'
    CATEGORY = 'http://www.2144.cn/html/'
    CATEGORY_NUM = 1..200
    DOWNLOAD = 'http://www.2144.cn/down.php?id='
  end

  def find_url 
    down = URL2144::DOWNLOAD
    
    # 从分类1开始，在分类页找游戏
    for i in URL2144::CATEGORY_NUM do
      begin
        url =  URL2144::CATEGORY + i.to_s
        puts url
        # 页面转码，显示游戏中文名
        page = open(url).read
        page = Iconv.iconv('utf-8', 'gbk', page)[0]
        page = Nokogiri::HTML(page)
        
        # 在分类页下端找到该分类的所有游戏链接
        links = page.css(".only_list a")

        # 该分类的游戏总数，页面上有显示
        puts "Games: #{links.size} 个"

        # 迭代每个游戏链接
        links.each do |link|
          begin
            game_url = link.attributes['href'].value
            swf_id = game_url.split('/').last
            
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
            download = Nokogiri::HTML(open down + swf_id)
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
            end
          rescue OpenURI::HTTPError
            puts "Open URL ERROR: #{down + swf_id}"
            puts "======================================"
          rescue EOFError
            puts "Network ERROR, Retry Connect"
            puts "======================================"
          rescue Errno::ECONNREFUSED
            puts "Connect REFUSED, Next connection"
            puts "======================================"
          end

          puts "#{name}"
          puts "#{swf_url}"
          Swf.create(:name => name, :url => swf_url, :category_id => "#{i}-#{swf_id}")
          puts "-----------------------------------------"

        end
      
      rescue OpenURI::HTTPError
        puts "Not find #{url}"
        puts "--------------------------------------------"
        next
      rescue EOFError
        puts "Network ERROR, Retry connect"
        puts "--------------------------------------------"
      rescue Errno::ECONNREFUSED
        puts "Connect Refused, Retry"
        puts "--------------------------------------------"
      end


    end
  end

end

if __FILE__ == $0
  require "#{File.dirname(__FILE__)}/../config/environment"
  Elss.new.find_url
end
