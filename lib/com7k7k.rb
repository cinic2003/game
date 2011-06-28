# incoding: utf-8
require 'spader'

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
  
  module COM7k7k
    WEB = 'http://www.7k7k.com/'
    URL = 'http://www.7k7k.com'
    CSS1 = '.tag dl dd a'
    CSS2 = '.bp ul li .i'
    CSS3 = '.c ul li .i'
    CSS4 = '.list ul li div div a'
  end

  def find_url
    # 根据css获取所有游戏的link
    links = @page.css(COM7k7k::CSS2) + @page.css(COM7k7k::CSS3)
    links.each do |link|
      # 通过游戏名来防止重复
      game_name = link.children.children.children[0]['alt']
      next if Swf.find_by_name(game_name)

      game_url = link.children.children[0].attributes['href'].value
      # 直接到游戏页面的链接,分为以flash和/special开头
      if game_url.start_with?('flash/')
        img_link = link.children.children.children[0].attributes
        img_url = img_link.has_key?('lz_src') ? img_link['lz_src'].value : img_link['src'].value

        # 直接从页面中的js中获取下载地址
        # swf_url = download_url_from_js(COM7k7k::WEB + game_url)
        swf_url = get_swf_url_from_js((COM7k7k::WEB+game_url), '_gamepath', /_gamepath\s=\s\"(.*\.(swf))/)
        unless swf_url.nil?
          Swf.create do |swf|
            swf.name = game_name
            swf.url = swf_url
            swf.image_url = img_url
            puts game_name
            puts swf_url
            puts img_url
            puts '------------------------------'
          end
        end
      end
    end
  
    # 获取首页所有链接以 tag/ 开始的专题
    tags = @page.css(COM7k7k::CSS1)
    tags.each do |tag|
      next unless tag.attributes['href'].value.start_with?('tag/')
      puts "专题: #{tag.children.text}"

      # 进入专题页面 抓取列表中的游戏
      swfs = get_game_url_from_category(tag.attributes['href'].value)
      next if swfs.nil?
      swfs.each do |array|
        if array[0].nil?
          puts "========================= #{array[2]}"
          next
        end
        swf_url = get_swf_url_from_js(array[2], '_gamepath', /_gamepath\s=\s\"(.*\.(swf))/)
        unless swf_url.nil?
          Swf.create do |swf|
            swf.name = array[0]
            swf.url = swf_url
            swf.image_url = array[1]
            puts array[0].to_s
            puts array[1].to_s
            puts swf_url
            puts '-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-='
          end
        end
      end
    end
    
    puts "Total : #{links.size + tags.size}"
  end
  
  def get_game_url_from_category(url)
    # 通过某一专题页面 查找该页面中的游戏链接
    tag_url = COM7k7k::WEB + url
    page = get_page_by_url(tag_url)
    return  if page.nil?
    swfs = []
    swfs += find_games(page)

    # 如果有分页
    pagies = page.css('.pager a').size
    if pagies > 0
      (2..pagies).each do |i|
        page_url = tag_url + 'index_' + i.to_s + '.htm'
        paginate_page = get_page_by_url(page_url)
        next if paginate_page.nil?
        swfs += find_games(paginate_page)
      end
    end
    swfs
  end

  def find_games(page)
    swfs = []
    page.css(COM7k7k::CSS4).each do |link|
      # 将每个游戏对应的名称 图片 url组成一个数组，在将所有这样的数组放在一个大数组中
      name = link.attributes['title'].value
      next if Swf.find_by_name(name)
      img = link.children[0].attributes['src'].value
      flash = COM7k7k::URL + link.attributes['href'].value
      swfs << [name, img, flash]
    end
    swfs
  end

  def test_tag(tag_url)
    swfs = get_game_url_from_category(tag_url)
    swfs.each do |swf|
      swf_url = get_swf_url_from_js(swf[2], '_gamepath', /_gamepath\s=\s\"(.*\.(swf))/)
      unless swf_url.nil?
        puts swf[0].to_s
        puts swf[1].to_s
        puts swf_url
        puts '-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-='
      end
    end
  end

end


if __FILE__ == $0
  require "#{File.dirname(__FILE__)}/../config/environment"
  url = 'http://www.7k7k.com'
  Com7k7k.new(url, 'utf-8').find_url#.each {|url| p find_swf(url)}
#  Com7k7k.new(url, 'utf-8').test_tag('tag/378/')
end
