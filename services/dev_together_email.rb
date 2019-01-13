require './services/google_sheets_service'
require './services/gmail_service'
require 'redcarpet'

class DevTogetherEmail
  PAIRING_SHEET_RANGE = "Pairing!A2:H50"
  EXPECTED_ROW_LENGTH = 8
  EVENT_DETAILS_SHEET_RANGE = "Event Details!A1:A7"
  MENTOR_EMAIL_SHEET_NAME = "Mentor Email"
  MENTEE_EMAIL_SHEET_NAME = "Mentee Email"
  MENTOR_AND_MENTEE_EMAIL_SHEET_RANGE = "A1:A2"

  def initialize(spreadsheet_id)
    @spreadsheet_id = spreadsheet_id
    @sheets_service = GoogleSheetsService.new
    @mail_service = GmailService.new
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
  end

  def run
    puts "Getting Pair data"
    pairing_rows = pairing_data.value_ranges[0].values
    puts "Got Pair data"

    puts "Getting Mentor email data"
    #determine path of mentor email markdown files
    mentor_email_dir = File.join(File.dirname(__FILE__), '../data/email/mentor')   
    #read each markdown accordingly
    mentor_subject = File.read("#{mentor_email_dir}/subject.md")
    mentor_body_format_string = File.read("#{mentor_email_dir}/body.md")
    puts "Got Mentor email data"
    
    puts "Getting Mentee email data"
    #determine path of mentee email markdown files
    mentee_email_dir = File.join(File.dirname(__FILE__), '../data/email/mentee')
    #read each markdown accordingly
    mentee_subject = File.read("#{mentee_email_dir}/subject.md")
    mentee_body_format_string = File.read("#{mentee_email_dir}/body.md")
    puts "Got Mentee email data"

    pairing_rows.each do |pairing_row|
      next if pairing_row.length < EXPECTED_ROW_LENGTH

      #send mentor email
      mentor_email = pairing_row[3]
      create_draft(pairing_row, mentor_email, mentor_subject, mentor_body_format_string)
      
      #send mentee email
      mentee_email = pairing_row[5]
      create_draft(pairing_row, mentee_email, mentee_subject, mentee_body_format_string)
    end
   
     #store mentor email into spreadsheet for future reference
     create_email_sheet("Mentor", MENTOR_EMAIL_SHEET_NAME, mentor_subject, mentor_body_format_string)

     #store mentee email into spreadsheet for future reference
     create_email_sheet("Mentee", MENTEE_EMAIL_SHEET_NAME, mentee_subject, mentee_body_format_string)

    puts "Done 💅"
  end

  private

  def pairing_data
    @pairing_data ||= @sheets_service.batch_get_values(@spreadsheet_id, [PAIRING_SHEET_RANGE])
  end

  def event_details_data
    @event_details_data ||= @sheets_service.batch_get_values(@spreadsheet_id, [EVENT_DETAILS_SHEET_RANGE])
  end

  def create_email_sheet(audience, sheet_name, subject, body) 
    puts "Creating #{audience} Email sheet for future reference"
    @sheets_service.add_sheet(@spreadsheet_id, sheet_name)
    
    puts "Updating #{audience} Email sheet with email details" 
    #create the update values
    update_values = []
    update_values << [].push(subject)
    update_values << [].push(body)
    @sheets_service.batch_update(@spreadsheet_id, "#{sheet_name}!#{MENTOR_AND_MENTEE_EMAIL_SHEET_RANGE}", update_values)
    puts "#{audience} Email sheet updates done"
  end

  def replace_pairing_and_event_data(input_string, pairing_row_data)
    # determine mentor and mentee details from pairing data
    mentor_name = pairing_row_data[2]
    mentor_email = pairing_row_data[3]
    mentee_name = pairing_row_data[4]
    mentee_email = pairing_row_data[5]
    mentee_code = pairing_row_data[6]
    mentee_feedback_requested = pairing_row_data[7]

    # determine event details from event details data
    event_day = event_details_data.value_ranges[0].values[0][0]
    event_date = event_details_data.value_ranges[0].values[1][0]
    event_start_time = event_details_data.value_ranges[0].values[2][0]
    event_city_name = event_details_data.value_ranges[0].values[3][0]
    sponsor_name = event_details_data.value_ranges[0].values[4][0]
    sponsor_address = event_details_data.value_ranges[0].values[5][0]
    food_info = event_details_data.value_ranges[0].values[6][0]

    # replace all tokens with appropriate data
    input_string.gsub('[MENTOR_NAME]', mentor_name)
                .gsub('[MENTOR_EMAIL]', mentor_email)
                .gsub('[MENTEE_NAME]', mentee_name)
                .gsub('[MENTEE_EMAIL]', mentee_email)
                .gsub('[MENTEE_CODE]', mentee_code)
                .gsub('[MENTEE_FEEDBACK]', mentee_feedback_requested)
                .gsub('[EVENT_DAY]', event_day)
                .gsub('[EVENT_DATE]', event_date)
                .gsub('[EVENT_START_TIME]', event_start_time)
                .gsub('[EVENT_CITY_NAME]', event_city_name)
                .gsub('[SPONSOR_NAME]', sponsor_name)
                .gsub('[SPONSOR_ADDRESS]', sponsor_address)
                .gsub('[FOOD_INFO]', food_info)
  end

  def create_draft(pairing_row_data, to, subject_format_string, body_format_string)
    subject = replace_pairing_and_event_data(subject_format_string, pairing_row_data)
    body = replace_pairing_and_event_data(body_format_string, pairing_row_data)
    body = @markdown.render(body)

    puts "Creating draft for #{to}"

    body += "#{@mail_service.signature}"
    #resp.message.id
    resp = @mail_service.create_draft(to: to, from: @mail_service.email_address, subject: subject, body: body)
  end
end