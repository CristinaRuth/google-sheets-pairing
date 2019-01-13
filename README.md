# google-sheets-pairing

A simple ruby CLI app for maximally matching data from Google sheets and creating draft emails.

The matcher (`matcher.rb`) is currently set up and configured to read Dev Together event registrations from our Google Form submissions and match Mentors and Mentees based on the languages and frameworks they have in common.

The code uses an iteration on the Edmonds matrix in order to calculate a maximum bipartite matching of the 2 data sets.

The mailer (`mailer.rb`) reads the the data written from the matcher and creates draft emails for you to send attendees. More info below.

## Getting Started

Clone the repo and run 
```
bundle install
```

You'll need to create a Google client secret in order to use the Sheets and Gmail API. [Follow step 1 here](https://developers.google.com/sheets/api/quickstart/ruby) or find the step by step below.

Copy the file into into the root of the repo and rename to `client_secret.json` if necessary.

1. Enable the API
  - Go to the [API Library](https://console.developers.google.com/apis/library)
  - Find your API and click 'Enable'
2. Download client credentials
  - Navigate to [APIs & Services > Credentials](https://console.developers.google.com/apis/credentials)
  - Click 'Create credentials'
  - Choose 'OAuth client ID' and give your client a name
  - Download the client credentials file for the OAuth client ID you just created (there's an icon for download on the right)

To send pairing emails, you'll need to maintain your own copy of the markdown files under `/data/email`. Samples have been provided to give you an idea of sample pairing emails to mentors and mentees.
1. Under `/data/email/mentee/`
  - Copy and paste the `body_sample.md` in the same directory. Rename the new file `body.md`.
  - Copy and paste the `subject_sample.md` in the same directory. Rename the new file `subject.md`.
2. Under `/data/email/mentor/`
  - Copy and paste the `body_sample.md` in the same directory. Rename the new file `body.md`.
  - Copy and paste the `subject_sample.md` in the same directory. Rename the new file `subject.md`.

The new files above will determine your email contents to mentors and mentees. Update them as you wish, but they are git-ignored, so they will not be checked into the repository. This is to allow each chapter to be able to maintain their own copy of the emails.

## Usage

### Running the matcher
```
ruby matcher.rb
```

You will be prompted for a Spreadsheet Id. This can be found in the url of your Google Sheets.

https://docs.google.com/spreadsheets/d/**the_id_is_found_here_and_is_rather_long**/edit#gid=0

You can also pass the argument in rather than wait for input 
```
ruby matcher.rb SPREADSHEET_ID
```

### Running the mailer
```
ruby mailer.rb
```
You will be prompted for a Spreadsheet Id. This can be found in the url of your Google Sheets.

https://docs.google.com/spreadsheets/d/**the_id_is_found_here_and_is_rather_long**/edit#gid=0

You can also pass the argument in rather than wait for input 
```
ruby mailer.rb SPREADSHEET_ID
```

`mailer.rb` expects 1 sheet in your Google Spreadsheet titled 'Event Details'.

The contents are parsed as follows:
* Cell A1 - Event Day (e.g. Tue)
* Cell A2 - Event Date (e.g. Nov 13)
* Cell A3 - Event Start Time (e.g. 6:00 PM)
* Cell A4 - City Name (e.g. Chicago)
* Cell A5 - Event Sponsor Name (e.g. Some Company Name)
* Cell A6 - Event Sponsor Address (e.g. 123 Main St, Chicago, IL)
* Cell A7 - Food Info (e.g. Food will be provided at this event.)

Mentor and Mentee email data are read locally from the folder `/data/email/mentor` or `/data/email/mentee`. Subject data is read from `subject.md` and body data is ready from `body.md`.

The markdown contents will be parsed and converted to HTML.

The following tokens in both the subject and body will be string replaced with the data from the 'Pairing' sheet.
- `[MENTOR_NAME]`
- `[MENTEE_EMAIL]`
- `[MENTEE_NAME]`
- `[MENTEE_EMAIL]`
- `[MENTEE_CODE]`
- `[MENTEE_FEEDBACK]`

Additionally, the following tokens in both the subject and body will be string replaced with the data from the 'Event Details' sheet.
- `[EVENT_DAY]`
- `[EVENT_DATE]`
- `[EVENT_START_TIME]`
- `[EVENT_CITY_NAME]`
- `[SPONSOR_NAME]`
- `[SPONSOR_ADDRESS]`
- `[FOOD_INFO]`

You do not need to include all of these in your email, but they are available for you.

#### First time running
The first time you run the CLI, you'll be presented with a link to follow that will grant the app the correct security access. Follow the link and then copy/paste the generated token into the command line. This will create and save your token file (`google_sheets_token.yaml` or `gmail_token.yaml`).

Note, you will need to do this for each API used so you may see this message more than once. This is granting the Google API access to your Google account in order to write to your spreadsheet (for the Sheets API) and to create drafts in your mailbox (for the Gmail API). 

Do not commit your token files to a repo. They should already be git ignored.

## Running the tests

```
bundle exec rspec
```

## Future features
- Automatically create email drafts to send to unmatched attendees

## Built With

* Ruby
* [Google Sheets Api](https://developers.google.com/sheets/api/samples/)
* [Gmail Api](https://developers.google.com/gmail/api/)
* [Mail](https://github.com/mikel/mail)


## Authors

* **Mercedes Bernard** 

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Max Bipartite Matching Algorithm inspired by: https://www.geeksforgeeks.org/maximum-bipartite-matching/
