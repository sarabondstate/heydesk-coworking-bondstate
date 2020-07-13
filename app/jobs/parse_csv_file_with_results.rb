class ParseCsvFileWithResults < ApplicationJob

  def perform(csv_string, job="", mail_message = [])
    require 'csv'

    current_line = 0

    begin
      line_count = csv_string.lines.count
      mail_messages << "Will try to parse #{line_count.to_s} results"
      CSV.parse(csv_string, col_sep: ';', headers: false) do |row|
        current_line += 1
        horse_attributes = {}
        %w(id number_of_starts first second third earned record_time record_time_auto).each_with_index do |key, index|
          horse_attributes[key.to_sym] = row[index].to_i unless key=='_'
        end
        horse = CommonHorse.find_by_sportsinfo_id(horse_attributes[:id])
        if horse
          horse.update_attribute(:winning_percentage, horse_attributes[:first].to_f / horse_attributes[:number_of_starts] * 100) if horse_attributes[:number_of_starts] > 0 and horse_attributes[:first] > 0
          horse.update_attributes(
              number_of_starts: horse_attributes[:number_of_starts],
              earnings_danish: horse_attributes[:earned],
              first_prices: horse_attributes[:first],
              second_prices: horse_attributes[:second],
              third_prices: horse_attributes[:third],
              record_time: (horse_attributes[:record_time] - 1000.0) / 10.0,
              record_time_auto: (horse_attributes[:record_time_auto] - 1000.0) / 10.0
          )
        end
      end
    rescue Exception => e
      DeveloperMessage.new_message(self.class, "Parsing failed: #{e.message}", job) 
      message = e.message + "<br/>\n" + e.backtrace.join("<br/>\n")
      WebHookMailer.failed_parsing(message)
      mail_messages << "FAILED: #{message}"
      p e
      puts e.backtrace.join("\n")
      puts "\n"
    end

    # Print status
    DeveloperMessage.new_message(self.class,"Parsed #{current_line}/#{line_count}", job)
    mail_messages << "Parsed #{current_line}/#{line_count}. New: #{new_horses} \n" 
    unless mail_messages.blank?
      message = mail_messages*"<br/>\n"
      WebHookMailer.import_done(message).deliver_now
    end
  end
end
