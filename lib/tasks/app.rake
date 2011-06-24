require 'open-uri'

namespace :app do
  desc '随机下载20个未下载过的flash'
  task :download_swf => :environment do
    puts "已存有flash url数: " + Swf.all.size.to_s
    for i in 1..20 do
      swf = Swf.un_download.has_image[rand(1000)]
      Resque.enqueue(DownFlash, swf.id)
    end
  end

  desc '下载未下载过的flash'
  task :download_all => :environment do
    Swf.un_download.each do |swf|
      Resque.enqueue(DownFlash, swf.id)
    end
  end

  desc 'whenever task test'
  task :whenever_test => :environment do 
    puts 'This is a whenever test'
  end
end
