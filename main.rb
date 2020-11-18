# frozen_string_literal: true

require 'optparse'
require 'open-uri'
require 'nokogiri'
require 'date'
require 'ruby-progressbar'

prs = {
  'hokkaido' => 10, 'aomori' => 22, 'iwate' => 20, 'miyagi' => 17, 'akita' => 18, 'yamagata' => 19, 'fukushima' => 21,
  'ibaraki' => 26, 'tochigi' => 28, 'gunma' => 25, 'saitama' => 29, 'chiba' => 27, 'tokyo' => 23, 'kanagawa' => 24,
  'niigata' => 31, 'toyama' => 37, 'ishikawa' => 34, 'fukui' => 36, 'yamanashi' => 32, 'nagano' => 30, 'gifu' => 39,
  'shizuoka' => 35, 'aichi' => 33, 'mie' => 38, 'shiga' => 45, 'kyoto' => 41, 'osaka' => 40, 'hyogo' => 42,
  'nara' => 44, 'wakayama' => 43, 'tottori' => 49, 'shimane' => 48, 'okayama' => 47, 'hiroshima' => 46,
  'yamaguchi' => 50, 'tokushima' => 53, 'kagawa' => 52, 'ehime' => 51, 'kochi' => 54, 'fukuoka' => 55, 'saga' => 61,
  'nagasaki' => 57, 'kumamoto' => 56, 'oita' => 60, 'miyazaki' => 59, 'kagoshima' => 58, 'okinawa' => 62, 'bs' => 98,
  'cs' => 99
}
d = {
  10 => '北海道', 22 => '青森', 20 => '岩手', 17 => '宮城', 18 => '秋田', 19 => '山形', 21 => '福島', 26 => '茨城', 28 => '栃木',
  25 => '群馬', 29 => '埼玉', 27 => '千葉', 23 => '東京', 24 => '神奈川', 31 => '新潟', 37 => '富山', 34 => '石川', 36 => '福井',
  32 => '山梨', 30 => '長野', 39 => '岐阜', 35 => '静岡', 33 => '愛知', 38 => '三重', 45 => '滋賀', 41 => '京都', 40 => '大阪',
  42 => '兵庫', 44 => '奈良', 43 => '和歌山', 49 => '鳥取', 48 => '島根', 47 => '岡山', 46 => '広島', 50 => '山口', 53 => '徳島',
  52 => '香川', 51 => '愛媛', 54 => '高知', 55 => '福岡', 61 => '佐賀', 57 => '長崎', 56 => '熊本', 60 => '大分', 59 => '宮崎',
  58 => '鹿児島', 62 => '沖縄', 98 => 'BS', 99 => 'CS'
}
area = d.keys
format = '%Y-%m-%d %H:%M'

opt = OptionParser.new
opt.on('-a', '--area pref1,pref2,...', Array, 'Prefectures (and/or bs, cs) to search (comma separated list)') do |a|
  if a != ['all']
    area = []
    a.each do |pr|
      if prs[pr].nil?
        puts "#{pr} is an invalid argument"
      else
        area << prs[pr]
      end
    end
  end
end
opt.on('-f', '--format VALUE', 'Set the date and time format (cf. Time#strftime)') { |f| format = f }
opt.banner += ' KEYWORD'
opt.parse!(ARGV)

def param(area)
  case area
  when 98
    '23&t=1'
  when 99
    '23&t=2'
  else
    "#{area}&t=3"
  end
end

def convtime(today, month, day, hour, min)
  time =
    if hour > 23
      Time.new(today.year, month, day, hour - 24, min) + 24 * 60 * 60
    else
      Time.new(today.year, month, day, hour, min)
    end
  time = Time.new(time.year + 1, time.month, time.day, time.hour, time.min) if time < today
  time
end

kywd = ARGV.join(' ')
today = Time.now - 24 * 60 * 60
list = []
pb = ProgressBar.create(
  title: "Searching for \"#{kywd}\"",
  total: area.length,
  format: '%t: |%B| %p%%',
  length: 75
)
area.each do |i|
  c = 10
  s = 1
  while c == 10
    url = URI.parse("https://tv.yahoo.co.jp/search/?q=#{URI.encode_www_form_component(kywd)}&a=#{param(i)}&s=#{s}")
    doc = Nokogiri::HTML.parse(url.open.read)
    programlist = doc.css('.programlist > li')
    programlist.each do |li|
      j = li.css('.leftarea > p > em')
      k = li.css('.rightarea > p')
      dm, dd = j[0].inner_text.split('/').map(&:to_i)
      st_h, st_m = j[1].inner_text.split('～')[0].split(':').map(&:to_i)
      date = convtime(today, dm, dd, st_h, st_m)
      list << {
        time: date,
        area: d[i],
        station: k[1].css('span')[0].inner_text.gsub(/（.+）/, ''),
        title: k[0].inner_text
      }
    end
    s += c = programlist.length
  end
  pb.increment
end

list.sort { |a, b| a[:time] <=> b[:time] }.each do |l|
  puts "#{l[:time].strftime(format)}\t#{l[:area]}\t#{l[:station]}\t#{l[:title]}"
end
