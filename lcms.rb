###
# gem install nokogiri
# gem install rest-client
# gem install mechanize
###

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

HOME_URL = ENV["LCMS_HOME_URL"]
login_url = "#{HOME_URL}/login.php"

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

a.get(login_url) do |page|
  frm = page.forms[0]
  frm["sitename"] = 'johnscreekeast'
  frm["username"] = ARGV[0]
  frm["password"] = ARGV[1]
  login_result = frm.submit

  puts login_result.parser.css('h3').text
end

