# encoding: utf-8

require 'rubygems'
require 'nokogiri'
require 'open-uri'

# 首页列表中的游戏
# 有游戏链接、图片链接、游戏名称 RECOMMAND_CONT CSS1
# 其中有些是专题
# 
# 分类专题
# 顶部导航的分类 TOP_TAG
# 专题推荐
# 游戏列表中分类 CSS2
# 专题链接形式
# 1. /zt/xxx /top/xxxx
# 2. /html/xxxx
# 3. http//

class Cn2144

  module CN2144
    URL = 'http://www.2144.cn'
    CATEGORY = 'http://www.2144.cn/html/'
    SWF_URL = 'http://flash.2144.cn/qigongzhu/'
    IMG_URL = 'http://img.2144.cn/'
    DOWNLOAD = 'http://www.2144.cn/down.php?id='

    TOP_TAG = "div[@id='topnavs_fonts']//dd//a"
    RECOMMEND_CONT = "dl[@id='recommend_cont']//dd//a"
    PROJECT_GAMES = "div[@id='project_games']//a"
    RECOMMEND_TAG = "div[@id='recommend_cont']//dl//dd//h5//a"

    CSS1 = ".games_lists a"
    CSS2 = ".typet_classimgs a"
    
  end

  def find_swf
    page = Nokogiri::HTML(open(CN2144::URL), nil, 'gb2312')
    
    # 分类找出首页的游戏和专题
    links = page.css(CN2144::CSS1) + page.search(CN2144::RECOMMEND_CONT) + page.css(CN2144::CSS2)
    tags = page.search(CN2144::TOP_TAG) + page.search(CN2144::PROJECT_GAMES)

    # 游戏 可直接获取图片 名称和该游戏链接
    links.each do |link|
      url = link.attributes['href'].value
      name = link.children.text
      if Swf.find_by_name(name).nil?
        image = link.children[0].attributes
        image_url = image.has_key?('src') ? image['src'].value : (CN2144::IMG_URL + image['a'].value)

        puts name 
        puts image_url

        # 通过分析游戏页面的js获取swf的url
        if url.start_with?('/html/')
          game_url = CN2144::URL + url
          swf_url = find_swf_url(game_url)
        else
          swf_url = ''
        end
        Swf.create(:name => name, 
                   :image_url => image_url,
                   :url => swf_url) unless swf_url.blank?
        puts swf_url
        puts '---------------'
      end
    end

    # 获取专题链接即可
    tags.each do |tag|
      name = tag.children[0].text
      puts "专题: #{name}"

      url = tag.attributes['href'].value
      if url.start_with?('/html/')
        tag_url = CN2144::URL + url
        swfs = find_swf_from_tag(tag_url)
        swfs.each do |swf|
          Swf.create(:name => swf[0], :image_url => swf[1], :url => swf[2]) unless swf[2].blank?
          puts swf[0]
          puts swf[1]
          puts swf[2]
        end

        # 是否有分页
        pages = page.css('.page a').children
        if pages.size > 0 
          pages.each  do |page|
            game_url = tag_url + 'index-' + page.to_s + '.htm'
            swfs = find_swf_from_tag(game_url)
            swfs.each do |swf|
              Swf.create(:name => swf[0], :image_url => swf[1], :url => swf[2]) unless swf[2].blank?
              puts swf[0]
              puts swf[1]
              puts swf[2]
            end
          end
        end

      end
    end
  end

  def find_swf_from_tag(tag_url)
    begin
      page = Nokogiri::HTML(open(tag_url), nil, 'gb2312')
    rescue Errno::ECONNREFUSED
      puts 'Connect Refused -----------------'
    rescue OpenURI::HTTPError
      puts 'HTTP Error ======================'
    end
    
    links = page.search(CN2144::RECOMMEND_TAG)
    swfs = []
    links.each do |link|
      name = link.children.text
      if Swf.find_by_name(name).nil?
        image_url = link.children[0].attributes['src'].value
        game_url = CN2144::URL + link.attributes['href']
        swf_url = find_swf_url(game_url)
        swfs << [name, image_url, swf_url]
      end
    end
    swfs
  end

  def find_swf_url(game_url)
    begin
      game_page = Nokogiri::HTML(open game_url)
    rescue Errno::ECONNREFUSED
      puts 'Connect Refused -----------------'
    rescue OpenURI::HTTPError
      puts 'HTTP Error ======================'
    rescue EOFError
      puts 'EOFFEroot >>>>>>>>>>>>>>>>>>>>>>>'
    end

    js = game_page.search('script').detect {|js| js.to_s.include?('game_filename')}
    unless js.to_s.scan(/game_filename=\'(.*\.(swf|htm))/).empty?
      swf_url = ($2 == 'swf') ? $1 : nil
      swf_url = swf_url.start_with?('http://') ? swf_url : (CN2144::SWF_URL + swf_url) unless swf_url.blank?
    end
    swf_url
  end

end

if __FILE__ == $0
  require "#{File.dirname(__FILE__)}/../config/environment"
  Cn2144.new.find_swf
end
