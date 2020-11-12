require "open-uri"
require "nokogiri"
require "date"
require "ruby-progressbar"

d = {10 => "北海道（札幌）", 11 => "北海道（函館）", 12 => "北海道（旭川）", 13 => "北海道（帯広）", 14 => "北海道（釧路）", 15 => "北海道（北見）", 16 => "北海道（室蘭）", 22 => "青森", 20 => "岩手", 17 => "宮城", 18 => "秋田", 19 => "山形", 21 => "福島", 23 => "東京", 24 => "神奈川", 29 => "埼玉", 27 => "千葉", 26 => "茨城", 28 => "栃木", 25 => "群馬", 32 => "山梨", 31 => "新潟", 30 => "長野", 37 => "富山", 34 => "石川", 36 => "福井", 33 => "愛知", 39 => "岐阜", 35 => "静岡", 38 => "三重", 40 => "大阪", 42 => "兵庫", 41 => "京都", 45 => "滋賀", 44 => "奈良", 43 => "和歌山", 49 => "鳥取", 48 => "島根", 47 => "岡山", 46 => "広島", 50 => "山口", 53 => "徳島", 52 => "香川", 51 => "愛媛", 54 => "高知", 55 => "福岡", 61 => "佐賀", 57 => "長崎", 56 => "熊本", 60 => "大分", 59 => "宮崎", 58 => "鹿児島", 62 => "沖縄", 99 => "衛星放送"}
area = [10,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,99]

t = Time.now - 24*60*60
list = []
pb = ProgressBar.create(
  :total => area.length
)
area.each {|i|
  if i == 99 then
    param = "&a=23&t=1+2"
  else
    param = "&a=" + i.to_s
  end
  c = 10
  s = 1
  while c == 10 do
    url = "https://tv.yahoo.co.jp/search/?q=" + URI.encode_www_form_component(ARGV[0]) + param + "&s=" + s.to_s
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

      list << date.strftime("%Y-%m-%d %H:%M") + " " + k[1].css("span")[0].inner_text.gsub(/（.+）/, "（#{d[i]}）") + "\t" + k[0].inner_text
    }
    s += c = programlist.length
  end
  pb.increment
}

puts list.sort