# frozen_string_literal: true

require 'optparse'
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

def set_param(key, genre, area, start)
  param = { 'query' => key, 'siTypeId' => '3', 'majorGenreId' => genre, 'areaId' => area.to_s,
            'start' => start }
  param['siTypeId'] = '1' if area == 99
  param
end

def search_request(key, genre, area, start)
  url = URI.parse('https://tv.yahoo.co.jp/api/adapter?_api=mindsSiQuery')
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  headers = { 'target-api' => 'mindsSiQuery', 'content-type' => 'application/json' }
  http.post(url, set_param(key, genre, area, start).to_json, headers)
end

def list_format(param)
  el = if param['element']
         param['element'].join
       else
         ''
       end
  { time: Time.at(param['broadCastStartDate']),
    area: param['areaName'],
    station: param['serviceName'],
    title: el + param['title'] }
end

def show_list(list, format)
  list.uniq.sort { |a, b| a[:time] <=> b[:time] }.each do |l|
    puts "#{l[:time].strftime(format)}\t#{l[:area].join(', ')}\t#{l[:station]}\t#{l[:title]}"
  end
end

def interactive_set(option, prs, gnrl)
  prompt = TTY::Prompt.new
  option['kywd'] = prompt.ask('Search keyword?', required: true)
  option['area'] = prompt.multi_select('Prefectures (and/or bs) to search?', prs)
  option['gnr'] = prompt.select('What genre to search?', gnrl)
  option['format'] = prompt.ask('Date and time format?', default: '%Y/%m/%d(%a) %H:%M')
  option['pbar'] = prompt.yes?('Show progress bar?')
end

option = {
  'kywd' => '',
  'area' => prs.values,
  'gnr' => '',
  'format' => '%Y/%m/%d(%a) %H:%M',
  'pbar' => true,
  'debug' => false
}

opt = OptionParser.new
opt.on('-d', '--debug', 'Debug mode') { option['debug'] = true }
opt.on('-i', '--interactive', 'Interactive mode') { option['interactive'] = true }
opt.on('-a', '--area pref1,pref2,...', Array, 'Prefectures (and/or bs) to search (comma separated list)') do |a|
  if a != ['all']
    option['area'] = []
    a.each do |pr|
      if prs[pr].nil?
        puts "\"#{pr}\" is an invalid argument"
        exit
      else
        option['area'] << prs[pr]
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
      option['gnr'] = gnrl[g]
      puts "Set \"#{g}\" as a genre to search" if option['debug']
    end
  end
end
opt.on('-f', '--format FORMAT', 'Set the date and time format (cf. Time#strftime).') { |f| option['format'] = f }
opt.on('-b', '--[no-]bar', 'Show (or not show) the progress bar.') { |b| option['pbar'] = b }
opt.banner += ' KEYWORD'
opt.parse!(ARGV)

if option['interactive']
  interactive_set(option, prs, gnrl)
else
  option['kywd'] = ARGV.join(' ')
  if option['kywd'] == ''
    puts '"KEYWORD" is required.'
    exit
  end
end

if option['pbar']
  pb = ProgressBar.create(
    title: "Searching for \"#{option['kywd']}\"",
    total: option['area'].length,
    format: '%t: |%B| %p%%',
    length: 75
  )
end
list = []
option['area'].each do |a|
  3.times do |s|
    res = search_request(option['kywd'], option['gnr'], a, s * 10)
    p res.code if option['debug']
    json = JSON.parse(res.body)['ResultSet']
    pp json if option['debug']
    json['Result'].each do |i|
      list << list_format(i)
    end
    break if json['attribute']['totalResultsReturned'] < 10
  end
  pb.increment if option['pbar']
end
show_list(list, option['format'])
