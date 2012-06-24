require 'nokogiri'
require 'rubygems'
require 'open-uri'
require 'icalendar'
require 'date'

include Icalendar

url = "https://www.sita-deutschland.de/loesungen/privathaushalte/abfuhrkalender/stuttgart.html?plz=70197&strasse=Rotenwaldstra%C3%9Fe&uid=3286"
doc = Nokogiri::HTML(open(url))

events = []
 
class String
  def squash
    self.length < 2 ? nil : self
  end
end

year = doc.xpath('//*[@id="c191"]/div/div/table/thead/tr/td/strong').text.split.last
entries = doc.xpath('//*[@id="c191"]/div/div/table/tbody/tr')
entries.each do |entry|
  events << entry.css('td')[1].text.split.last
  events << entry.css('td')[2].text.split.last.squash
end

cal = Calendar.new

events.compact.each do |entry|
  cal.event do
    dtstart Date.strptime(entry,'%d.%m.%Y')
    summary 'Gelber Sack wird abgeholt'
    alarm do
      summary 'Gelber Sack wird morgen abgeholt'
      action 'DISPLAY'
      trigger '-PT5H0M0S'
    end
  end
end

cal_file = File.new(File.join(ENV['HOME'],'Desktop/waste.ics'), 'w')
cal_file.write(cal.to_ical)
cal_file.close