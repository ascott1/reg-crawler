# based on the web crawler featured in http://ruby.bastardsbook.com/

require 'rubygems'
require 'nokogiri'
require 'open-uri'

DATA_DIR = "regs"
Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)

HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

# adjust the value of this variable to pull down regulations from 1996 - present
reg_year = 1996
 
page = Nokogiri::HTML(open("http://www.gpo.gov/fdsys/browse/collectionCfr.action?selectedYearFrom=#{reg_year}&go=Go"))   
hrefs = page.css(".cfr-download-links a:contains('Text')").map{ |a| 
    a['href']
  }.compact.uniq

hrefs.each do |href|
    remote_url =  href
    simple_fname = File.basename(href)
    simple_fname = (["CFR"] + simple_fname.split(".")[0].split("-").slice(2, 2)).join("-") + ".txt"
    local_fname = "#{DATA_DIR}/#{simple_fname}"
    unless File.exists?(local_fname)
      puts "Fetching #{remote_url}..."
      begin
        wiki_content = open(remote_url, HEADERS_HASH).read
      rescue Exception=>e
        puts "Error: #{e}"
        sleep 5
      else
        File.open(local_fname, 'w'){|file| file.write(wiki_content)}
        puts "\t...Success, saved to #{local_fname}"
      ensure
        sleep 1.0 + rand
      end  # done: begin/rescue
    end # done: unless File.exists? 
end # done: hrefs.each