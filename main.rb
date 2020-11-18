require "optparse"
require "open-uri"
require "nokogiri"
require "date"
require "ruby-progressbar"

prs = {"hokkaido" => 10, "aomori" => 22, "iwate" => 20, "miyagi" => 17, "akita" => 18, "yamagata" => 19, "fukushima" => 21, "ibaraki" => 26, "tochigi" => 28, "gunma" => 25, "saitama" => 29, "chiba" => 27, "tokyo" => 23, "kanagawa" => 24, "niigata" => 31, "toyama" => 37, "ishikawa" => 34, "fukui" => 36, "yamanashi" => 32, "nagano" => 30, "gifu" => 39, "shizuoka" => 35, "aichi" => 33, "mie" => 38, "shiga" => 45, "kyoto" => 41, "osaka" => 40, "hyogo" => 42, "nara" => 44, "wakayama" => 43, "tottori" => 49, "shimane" => 48, "okayama" => 47, "hiroshima" => 46, "yamaguchi" => 50, "tokushima" => 53, "kagawa" => 52, "ehime" => 51, "kochi" => 54, "fukuoka" => 55, "saga" => 61, "nagasaki" => 57, "kumamoto" => 56, "oita" => 60, "miyazaki" => 59, "kagoshima" => 58, "okinawa" => 62, "bs" => 98, "cs" => 99}
d = {10 => "北海道", 22 => "青森", 20 => "岩手", 17 => "宮城", 18 => "秋田", 19 => "山形", 21 => "福島", 26 => "茨城", 28 => "栃木", 25 => "群馬", 29 => "埼玉", 27 => "千葉", 23 => "東京", 24 => "神奈川", 31 => "新潟", 37 => "富山", 34 => "石川", 36 => "福井", 32 => "山梨", 30 => "長野", 39 => "岐阜", 35 => "静岡", 33 => "愛知", 38 => "三重", 45 => "滋賀", 41 => "京都", 40 => "大阪", 42 => "兵庫", 44 => "奈良", 43 => "和歌山", 49 => "鳥取", 48 => "島根", 47 => "岡山", 46 => "広島", 50 => "山口", 53 => "徳島", 52 => "香川", 51 => "愛媛", 54 => "高知", 55 => "福岡", 61 => "佐賀", 57 => "長崎", 56 => "熊本", 60 => "大分", 59 => "宮崎", 58 => "鹿児島", 62 => "沖縄", 98 => "BS", 99 => "CS"}
area = d.keys
format = "%Y-%m-%d %H:%M"

opt = OptionParser.new
opt.on('-a', '--area pref1,pref2,...', Array, "Prefectures (and/or bs, cs) to search (comma separated list)") {|al|
  if al == ["all"] then
  else
    area = []
    al.each {|pr|
      if prs[pr] == nil then
        puts "#{pr} is an invalid argument"
      else
        area << prs[pr]
      end
    }
  end
}
opt.on('-f', '--format VALUE', "Set the date and time format (cf. Time#strftime)") {|f|
  format = f
}
opt.banner += ' KEYWORD'
opt.parse!(ARGV)

kywd = ARGV.join(" ")
t = Time.now - 24*60*60
list = []
pb = ProgressBar.create(
  :title => "Searching for \"#{kywd}\"",
  :total => area.length,
  :format => "%t: |%B| %p%%",
  :length	=> 75
)
area.each {|i|
  if i == 98 then
    param = "&a=23&t=1"
  elsif i == 99 then
    param = "&a=23&t=2"
  else
    param = "&a=" + i.to_s + "&t=3"
  end
  c = 10
  s = 1
  while c == 10 do
    url = "https://tv.yahoo.co.jp/search/?q=" + URI.encode_www_form_component(kywd) + param + "&s=" + s.to_s
    html = URI.open(url) do |f|
      charset = f.charset
      f.read
    end

    doc = Nokogiri::HTML.parse(html)
    programlist = doc.css(".programlist > li")
    programlist.each {|li|
      j = li.css(".leftarea > p > em")
      k = li.css(".rightarea > p")
      dm, dd = j[0].inner_text.split("/").map(&:to_i)
      st_h, st_m = j[1].inner_text.split("～")[0].split(":").map(&:to_i)
      if st_h > 23 then
        date = Time.new(t.year, dm, dd, st_h - 24, st_m) + 24*60*60
      else
        date = Time.new(t.year, dm, dd, st_h, st_m)
      end
      # 年明け判定
      if date < t then
        date = Time.new(date.year + 1, date.month, date.day, date.hour, date.min)
      end

      list << date.strftime(format) + " " + k[1].css("span")[0].inner_text.gsub(/（.+）/, "（#{d[i]}）") + "\t" + k[0].inner_text
    }
    s += c = programlist.length
  end
  pb.increment
}

puts list.sort