require 'task_helpers/csv_import_helper'
namespace :csv_import do
  desc "Check mail for csv files to import"
  task import: :environment do
    DeveloperMessage.new_message(self.class, "CSV IMPORT", "RAKE")
    Rails.logger.info "Checking mail for csv files to import"
    # Connect to our csv mail account
    # Pseudo code to explain the process:
    # For each unflagged email in inbox:
    #   if it has relevant attachments (ends with .txt or .csv):
    #     if it looks like the right format (seperated by ; and has correct number of columns):
    #       Parse the attachment (though perform it "later" on another Heroku worker)
    #       Mark email as read and "flag"/"star" it so we don't parse it again
    #   if no attachment where parsed:
    #     Delete the email
    Gmail.connect('csv.mosson@houseofcode.io', 'eneseCIA') do |gmail|
      Rails.logger.info "Connected to inbox"
      job = "#{self.class}: #{DateTime.now.to_s}"
      gmail.inbox.find(:unflagged).each do |email|
        result_messages = []
        result_messages << "Email with subject: <b>#{email.subject}</b>"
        Rails.logger.info "Email with subject: #{email.subject}"
        parsed_attachment = false
        email.message.attachments.each do |f|
          next unless f.filename.end_with?('.txt', '.csv')
          attachment_content = f.body.decoded.encode('UTF-8', 'iso-8859-1')
          columns = attachment_content.lines.first.gsub(/\n/,"").split(';').count
          result_messages << "Mail has attachment: <b>#{f.filename}</b>"
          Rails.logger.info "Mail has attachment: #{f.filename}"
          if columns == 23 || columns == 24 # When 24 columns it has an extra field given in the DG file 
            DeveloperMessage.new_message(self.class, "Will try to parse attachment with horse data", job)
            CSVImportHelper.parse_horses(attachment_content, job, result_messages)
            parsed_attachment = true
          elsif columns == 9
            DeveloperMessage.new_message(self.class, "Will try to parse attachment with results", job)
            CSVImportHelper.parse_results(attachment_content, job, result_messages)
            parsed_attachment = true
          else
            result_messages << "No a suitable attachment!"
          end
        end
        email.read!
        if parsed_attachment
          email.archive!
          email.star!
          next
        else
          message = result_messages*"<br/>\n"
          WebHookMailer.import_done(message).deliver_now
        end
        email.delete!
      end
    end
  end
end
