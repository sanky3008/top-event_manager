require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phonenumber(phone_number)
  phone_number = phone_number.delete(' ().-')

  if (
    phone_number.length < 10 ||
    (phone_number.length == 11 && phone_number[0] != '1') ||
    phone_number.length > 11
  )
    phone_number = '0000000000'
  elsif (
    phone_number.length == 10
  )
    phone_number
  elsif (
    (phone_number.length == 11 && phone_number[0] == '1')
  )
    phone_number.chr
  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'
hour_data = Hash.new(0)
day_data = Hash.new(0)

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])

  hour_data[Time.strptime(row[:regdate], '%m/%d/%y %H:%M').hour] += 1
  day_data[Time.strptime(row[:regdate], "%m/%d/%y %H:%M").strftime('%A')] += 1

  # puts "#{name}, #{clean_phonenumber(row[:homephone])}, #{clean_phonenumber(row[:homephone]).length}"

  # home_phone = clean_phonenumber(row[:HomePhone])
  # legislators = legislators_by_zipcode(zipcode)

  # form_letter = erb_template.result(binding)

  # save_thank_you_letter(id,form_letter)
end

puts hour_data
puts day_data
