###
# gem install nokogiri
# gem install rest-client
# gem install mechanize
###

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

HOME_URL = ENV["JGLOBAL_HOME_URL"]
login_url = "#{HOME_URL}/login"
wb_report_url = "#{HOME_URL}/member/workbooks.cfm"

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

# login
a.get(login_url) do |page|
  frm = page.forms[0]
  frm["id"] = ARGV[0]
  frm["password"] = ARGV[1]
  login_result = frm.submit

  puts "Logged in..."
end

### sample data format
# {
#   "2017"=>{
#     "2"=>{
#       "AAA ZZZ"=>{
#         :EE=>["A05", "A06", "A07", "A08", "A09", "A10", "A11", "A12"], 
#         :EM=>[], 
#         :ER=>[]},      
#       "BBB CCC"=>{
#         :EE=>["E14", "E15", "E16", "E17", "E19", "E20", "E22", "E25"], 
#         :EM=>["G21", "G22", "G23", "F09P", "G24", "G25", "G26", "F10P"], 
#         :ER=>[]}
#       "DDD EEE"=>{
#         :EE=>[], 
#         :EM=>[], 
#         :ER=>["E05-4", "E06-1", "E06-2", "E06-3", "E06-4", "E07-1", "E07-2", "E07-3"]},
#       "SSS NNN"=>{
#         :EE=>["E27", "E30", "E-REV", "", "", "", "", ""], 
#         :EM=>["H14", "H15", "H16", "H17", "H18", "H19", "H20", "H21"], 
#         :ER=>[]}          
#       }
#   }
# }

# workbook report
repYear = "2017"
repMonth = "2"
a.get(wb_report_url) do |page|
  frm = page.forms[0]
  frm["thisYear"] = repYear
  frm["thisMonth"] = repMonth
  frm["thisWeeks"] = "month"
  wbr_result = frm.submit
  
  # init data hash
  student_monthly_wb = {repYear => {repMonth => {}}}
  student_wb = {}

  rows = wbr_result.parser.css(".gridTable tr")
  puts "#{rows.count} rows found in workbook report."
  # skip first row of header and start data from next row
  rows[1..-2].each do |row|
    cols = row.css(".gridCell")
    student =  cols[1]['title']
    student_wb = {student => {:EE => [], :EM => [], :ER => []}}
    (5..12).each do |index|
      eng_tb = cols[index].css("input[mpsubjectnamecode='EE']")
      if eng_tb != nil && eng_tb.count !=0
        #print eng_tb[0]['value'] + "|"
        student_wb[student][:EE] << eng_tb[0]['value']
      end
    end
    (5..12).each do |index|
      math_tb = cols[index].css("input[mpsubjectnamecode='EM']")
      if math_tb != nil && math_tb.count !=0
        # print math_tb[0]['value'] + "|"
        student_wb[student][:EM] << math_tb[0]['value']
      end
    end
    (5..12).each do |index|
      rw_tb = cols[index].css("input[mpsubjectnamecode='ER']")
      if rw_tb != nil && rw_tb.count !=0
        # print math_tb[0]['value'] + "|"
        student_wb[student][:ER] << rw_tb[0]['value']
      end
    end
    student_monthly_wb[repYear][repMonth].merge!(student_wb)
  end  
  puts student_monthly_wb
end
