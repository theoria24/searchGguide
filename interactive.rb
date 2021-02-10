# frozen_string_literal: true

require 'tty-prompt'
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
  'all' => '', 'news' => '0x0', 'sports' => '0x1', 'info' => '0x2', 'drama' => '0x3', 'music' => '0x4',
  'variety' => '0x5', 'movie' => '0x6', 'anime' => '0x7', 'documentary' => '0x8', 'performance' => '0x9',
  'education' => '0xA', 'welfare' => '0xB', 'other' => '0xF'
}

prompt = TTY::Prompt.new
kywd = prompt.ask('Search keyword?', required: true)
area = prompt.multi_select('Prefectures (and/or bs) to search?', prs)
gnr = prompt.select('What genre to search?', gnrl)
format = prompt.ask('Date and time format?', default: '%Y/%m/%d(%a) %H:%M')
pbar = prompt.yes?('Show progress bar?')
debug = !prompt.no?('Debug mode?')

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
