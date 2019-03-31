require './services/general_email'

if ARGV[0]
  sheet_id = ARGV[0]
else
  puts 'Sheet Id:'
  sheet_id = gets.chomp
end

general_email = GeneralEmail.new(sheet_id)
general_email.run
