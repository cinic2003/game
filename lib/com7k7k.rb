# incoding: utf-8
require 'spader'
require 'rubygems'

# 1.网页游戏 http://web.7k7k.com/xxxxx  css_3
#
# 2.专题游戏:
#   http://news.7k7k.com/xxxx           css_3
#   tag/xxx/ 在页面头部分类列表中       css_1
#
# 3.直接flash游戏:
#   /special/xxxx 直接进入游戏页面                css_2
#   flash/xxxx.html 通过该页面到游戏页面/swf/xxxx css_2
# 
# css_1 .tag dl dd a   头部分类css
# css_2 .bp ul li      游戏列表中游戏css
# css_3 .c ul li       游戏列表中专题css


class Com7k7k < Spader
  
  module Com7k7k
    WEB = 'http://www.7k7k.com/'
    URL = 'http://www.7k7k.com'
    CSS1 = '.tag dl dd a'
    CSS2 = '.bp ul li .i'
    CSS3 = '.c ul li .i'
    CSS4 = '.list ul li .i'
  end

  def find_url
    # 根据css获取所有游戏的link
    links = @page.css(Com7k7k::CSS2) + @page.css(Com7k7k::CSS3)
    links.each do |link|
      game_url = link.children.children[0].attributes['href'].value
      # 直接到游戏页面的链接,分为以flash和/special开头
      if game_url.start_with?('flash/')
        img_link = link.children.children.children[0].attributes
        img_url = img_link.has_key?('lz_src') ? img_link['lz_src'].value : img_link['src'].value
        game_name = link.children.children.children[0]['alt']

        if Swf.find_by_name(game_name).nil?
          # 直接从页面中的js中获取下载地址
          swf_url = download_url_from_js(Com7k7k::WEB + game_url)
          Swf.create(:name => game_name, :url => swf_url, :image_url => img_url, :web => (Com7k7k::WEB + game_url)) unless swf_url.nil?
          puts game_name
          puts swf_url
          puts img_url
          puts '------------------------------'
        end
      end
    end
  
    # 获取首页所有链接以 tag/ 开始的专题
    tags = @page.css(Com7k7k::CSS1)
    tags.each do |tag|
      puts "专题: #{tag.children.text}"

      # 进入专题页面 抓取列表中的游戏
      swfs = get_game_url_from_category(tag.attributes['href'].value)
        
      swfs.each do |swf|
        swf_url = download_url_from_js(swf[2])
        Swf.create(:name => swf[0], :url => swf_url, :image_url => swf[1], :web => swf[2]) unless swf_url.nil?
        puts swf[0]
        puts swf[1]
        puts swf_url
        puts '------------------------------'
      end
    end
    
    puts "Total : #{links.size + tags.size}"
  end
  
  # 从页面的js中获取swf地址
  def download_url_from_js(url)
    retry_count = 0
    begin
      game_page = Nokogiri::HTML(open url)
    rescue OpenURI::HTTPError
      sleep 50
      retry_count += 1
      retry_count < 10 ? retry : next
    rescue Errno::ECONNREFUSED
      sleep 50
      retry_count += 1
      retry_count < 10 ? retry : next
    end

    js = game_page.search('script').detect {|j| j.children[0].to_s.include?('_gamepath')}
    unless js.to_s.scan(/_gamepath\s=\s\"(.*\.(swf|html|htm|dcr))/).empty?
    download_url = ($2 == 'swf') ? $1 : nil
    end
  end

  def get_game_url_from_category(url)
    # 通过某一专题页面 查找该页面中的游戏链接
    tag_url = Com7k7k::WEB + url
    page = Nokogiri::HTML(open tag_url)
    swfs = []
    swfs += find_games(page)

    # 如果有分页
     pagies = page.css('.pager a').size
     if pagies > 0
      (2..pagies).each do |i|
        page_url = tag_url + 'index_' + i.to_s + '.htm'
        paginate_page = Nokogiri::HTML(open page_url)
        swfs += find_games(paginate_page)
      end
    end
    swfs
  end

  def find_games(page)
    swfs = []
    page.css(Com7k7k::CSS4).each do |link|
      # 将每个游戏对应的名称 图片 url组成一个数组，在将所有这样的数组放在一个大数组中
      name = link.children.children[0].attributes['title'].value
      if Swf.find_by_name(name).nil?
        img = link.children.children.children[0].attributes['src'].value
        flash = Com7k7k::URL + link.children.children[0].attributes['href'].value
        swfs << [name, img, flash]
      end
    end
    swfs
  end

end


if __FILE__ == $0
  require "#{File.dirname(__FILE__)}/../config/environment"
  url = 'http://www.7k7k.com'
  Com7k7k.new(url).find_url#.each {|url| p find_swf(url)}
  #  qkqk = Com7k7k.new(url)
  #  urls = qkqk.get_game_url_from_category('http://news.7k7k.com/lanqiu/lanqiuzt/')
  #  urls.each do |url|
  #    puts url[0]
  #    qkqk.download_url_from_js(url[1])
  #  end
end
