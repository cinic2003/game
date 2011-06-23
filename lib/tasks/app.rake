require 'open-uri'

namespace :app do
  desc "随机下载20个flash游戏"
  task :download_swf => :environment do
    puts "已存有flash url数: " + Swf.all.size.to_s
    for i in 1..20 do
      swf = Swf.all[rand(1000)]
      puts "Download the flash:" + swf.name
      f = open(swf.url).read
      File.open("#{Rails.root}/tmp/#{swf.name}", "w") do |file|
        puts swf.url
        file.write f
        puts "Download success"
      
      end
    end
  end

  desc 'whenever task test'
  task :whenever_test => :environment do 
    puts 'This is a whenever test'
  end
end
