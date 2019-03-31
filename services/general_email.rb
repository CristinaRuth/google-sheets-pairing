require './services/google_sheets_service'
require './services/gmail_service'
require 'redcarpet'

class GeneralEmail
  # Specify sheet range of email data. Start at row 2 so we don't read the headers of the first row.
  CONTACTS_SHEET_RANGE = "Contacts!A2:B50"
  # How many columns are we expecting?
  EXPECTED_ROW_LENGTH = 2
  # Email Sheet that we are going to save the email to.
  EMAIL_SHEET_NAME = "Email"
  EMAIL_SHEET_RANGE = "A1:A2"

  def initialize(spreadsheet_id)
    @spreadsheet_id = spreadsheet_id
    @sheets_service = GoogleSheetsService.new
    @mail_service = GmailService.new
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
  end

  def run
    puts "Getting Contacts data"
    contacts_rows = contacts_data.value_ranges[0].values
    puts "Got Contacts data"

    puts "Getting email data"
    #determine path of email markdown files
    email_dir = File.join(File.dirname(__FILE__), '../data/email/general')   
    #read each markdown accordingly
    subject = File.read("#{email_dir}/subject.md")
    body_format_string = File.read("#{email_dir}/body.md")
    puts "Got email data"

    contacts_rows.each do |contact_row|
      next if contact_row.length < EXPECTED_ROW_LENGTH

      #send email
      email = contact_row[1]
      puts "...Reading email from row data. Result: #{email}"
      create_draft(contact_row, email, subject, body_format_string)
    end
   
     #store email into spreadsheet for future reference
     create_email_sheet("General", EMAIL_SHEET_NAME, subject, body_format_string)

    puts "Done 💅"
  end

  private

  def contacts_data
    @contacts_data ||= @sheets_service.batch_get_values(@spreadsheet_id, [CONTACTS_SHEET_RANGE])
  end

  def create_email_sheet(audience, sheet_name, subject, body) 
    puts "Creating #{audience} Email sheet for future reference"
    @sheets_service.add_sheet(@spreadsheet_id, sheet_name)
    
    puts "Updating #{audience} Email sheet with email details" 
    #create the update values
    update_values = []
    update_values << [].push(subject)
    update_values << [].push(body)
    @sheets_service.batch_update(@spreadsheet_id, "#{sheet_name}!#{EMAIL_SHEET_RANGE}", update_values)
    puts "#{audience} Email sheet updates done"
  end

  def replace_data(input_string, pairing_row_data)
    # determine mentor and mentee details from pairing data
    name = pairing_row_data[0]
    
    # replace all tokens with appropriate data
    input_string.gsub('[NAME]', name)
  end

  def create_draft(pairing_row_data, to, subject_format_string, body_format_string)
    subject = replace_data(subject_format_string, pairing_row_data)
    body = replace_data(body_format_string, pairing_row_data)
    body = @markdown.render(body)

    puts "Creating draft for #{to}"

    body += "#{@mail_service.signature}"
    #resp.message.id
    resp = @mail_service.create_draft(to: to, from: @mail_service.email_address, subject: subject, body: body)
  end
end