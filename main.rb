# frozen_string_literal: true

require 'optparse'
require 'open-uri'
require 'net/http'
require 'json'
require 'date'
require 'ruby-progressbar'

prs = {
  'hokkaido' => 10, 'aomori' => 22, 'iwate' => 20, 'miyagi' => 17, 'akita' => 18, 'yamagata' => 19, 'fukushima' => 21,
  'ibaraki' => 26, 'tochigi' => 28, 'gunma' => 25, 'saitama' => 29, 'chiba' => 27, 'tokyo' => 23, 'kanagawa' => 24,
  'niigata' => 31, 'toyama' => 37, 'ishikawa' => 34, 'fukui' => 36, 'yamanashi' => 32, 'nagano' => 30, 'gifu' => 39,
  'shizuoka' => 35, 'aichi' => 33, 'mie' => 38, 'shiga' => 45, 'kyoto' => 41, 'osaka' => 40, 'hyogo' => 42,
  'nara' => 44, 'wakayama' => 43, 'tottori' => 49, 'shimane' => 48, 'okayama' => 47, 'hiroshima' => 46,
  'yamaguchi' => 50, 'tokushima' => 53, 'kagawa' => 52, 'ehime' => 51, 'kochi' => 54, 'fukuoka' => 55, 'saga' => 61,
  'nagasaki' => 57, 'kumamoto' => 56, 'oita' => 60, 'miyazaki' => 59, 'kagoshima' => 58, 'okinawa' => 62, 'bs' => 99
}
gnrl = {
  'news' => '0x0', 'sports' => '0x1', 'info' => '0x2', 'drama' => '0x3', 'music' => '0x4', 'variety' => '0x5',
  'movie' => '0x6', 'anime' => '0x7', 'documentary' => '0x8', 'performance' => '0x9', 'education' => '0xA',
  'welfare' => '0xB', 'other' => '0xF'
}
area = prs.values
gnr = ''
format = '%Y/%m/%d(%a) %H:%M'
pbar = true
debug = false

opt = OptionParser.new
opt.on('-a', '--area pref1,pref2,...', Array, 'Prefectures (and/or bs) to search (comma separated list)') do |a|
  if a != ['all']
    area = []
    a.each do |pr|
      if prs[pr].nil?
        puts "\"#{pr}\" is an invalid argument"
        exit
      else
        area << prs[pr]
      end
    end
  end
end
opt.on('-g', '--genre GENRE', 'Set the genre of the program to search') do |g|
  if g != ['all']
    if gnrl[g].nil?
      puts "\"#{g}\" is an invalid genre"
      exit
    else
      gnr = gnrl[g]
      puts "Set \"#{g}\" as a genre to search" if debug
    end
  end
end
opt.on('-f', '--format FORMAT', 'Set the date and time format (cf. Time#strftime).') { |f| format = f }
opt.on('-b', '--[no-]bar', 'Show (or not show) the progress bar.') { |b| pbar = b }
opt.on('-d', '--debug', 'Debug mode') { debug = true }
opt.banner += ' KEYWORD'
opt.parse!(ARGV)

kywd = ARGV.join(' ')
if kywd == ''
  puts '"KEYWORD" is required.'
  exit
end

def set_param(kywd, genre, area, start)
  param = { 'query' => kywd, 'siTypeId' => '3', 'majorGenreId' => '', 'areaId' => '23', 'start' => 0 }
  if area == 99
    param['siTypeId'] = '1'
  else
    param['areaId'] = area.to_s
  end
  param['majorGenreId'] = genre
  param['start'] = start
  param
end

url = URI.parse('https://tv.yahoo.co.jp/api/adapter')
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
headers = { 'target-api' => 'mindsSiQuery', 'content-type' => 'application/json' }

list = []
if pbar
  pb = ProgressBar.create(
    title: "Searching for \"#{kywd}\"",
    total: area.length,
    format: '%t: |%B| %p%%',
    length: 75
  )
end

area.each do |a|
  c = 10
  s = 0
  while c == 10 && s < 30
    c = 0
    res = http.post(url.path, set_param(kywd, gnr, a, s).to_json, headers)
    p res.code if debug
    json = JSON.parse(res.body)
    pp json if debug
    json['ResultSet']['Result'].each do |i|
      el = if i['element']
             i['element'].join
           else
             ''
           end
      list << {
        time: Time.at(i['broadCastStartDate']),
        area: i['areaName'],
        station: i['serviceName'],
        title: el + i['title']
      }
      s += 1
      c += 1
    end
  end
  pb.increment if pbar
end

list.uniq.sort { |a, b| a[:time] <=> b[:time] }.each do |l|
  puts "#{l[:time].strftime(format)}\t#{l[:area].join(', ')}\t#{l[:station]}\t#{l[:title]}"
end
