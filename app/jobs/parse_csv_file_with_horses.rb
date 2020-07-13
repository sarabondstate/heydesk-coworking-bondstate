class ParseCsvFileWithHorses < ApplicationJob
  def perform(csv_string, job="", mail_messages = [])
    parse(csv_string, job, mail_messages)
  end

  def parse(csv_string, job="", mail_messages = [])
    require 'csv'

    current_line = 0
    new_horses = 0

    begin
      line_count = csv_string.lines.count
      mail_messages << "Will try to parse #{line_count.to_s} horses"
      Rails.logger.info "Will try to parse #{line_count.to_s} horses: mail messages: #{mail_messages}"
      CSV.parse(csv_string, col_sep: ';', headers: false) do |row|
        current_line += 1
        #if current_line % 10 == 0
        #  Rails.logger.info "Parsing #{current_line}/#{line_count}. New: #{new_horses}\r"
        #  $stdout.flush
        #end
        horse_attributes = {}
        %w(id name country gender birth_year father_id mother_id _ _ _ _ _ _ import_export exported premier_race premier_race_date qualifying_race qualifying_race_date trainer_id trainer_name horse_registration).each_with_index do |key, index|
          horse_attributes[key.to_sym] = row[index] unless key=='_'
        end

        # Trainer:
        trainer_id = horse_attributes[:trainer_id].to_i
        # 999990 is an id for "ukendt træner"
        if trainer_id > 0 and trainer_id!=999990
          import_trainer = ImportTrainer.find_by_sportsinfo_id(trainer_id)
          if import_trainer.nil?
            import_trainer = ImportTrainer.create(name: horse_attributes[:trainer_name], sportsinfo_id: trainer_id)
          end
        end

        # Horse:
        common_horse = CommonHorse.find_by_registration_number(horse_attributes[:horse_registration])
        if common_horse.nil?
          new_horses += 1
          update_existing_horse(CommonHorse.new, horse_attributes, import_trainer)
        else
          update_existing_horse(common_horse, horse_attributes, import_trainer)
        end
      end
    rescue Exception => e
      
      DeveloperMessage.new_message(self.class, "Parsing failed: #{e.message}", job) 
      message = e.message + "<br/>\n" + e.backtrace.join("<br/>\n")
      WebHookMailer.failed_parsing(message).deliver_now
      mail_messages << "FAILED: #{message}"
      Rails.logger.info "Error: #{message}" 
    end

    Rails.logger.info "Done" 

    # Print status
    DeveloperMessage.new_message(self.class, "Parsed #{current_line}/#{line_count}. New: #{new_horses} \n", job)
    mail_messages << "Parsed #{current_line}/#{line_count}. New: #{new_horses} \n" 
    unless mail_messages.blank?
      message = mail_messages*"<br/>\n"
      Rails.logger.info "Messages: #{message}" 
      WebHookMailer.import_done(message).deliver_now
    end
  end


  private
  def update_existing_horse(common_horse, horse_attributes, import_trainer)
    father_name = common_horse.dad
    if father_name=='' and father = CommonHorse.find_by_sportsinfo_id(horse_attributes[:father_id])
      father_name = father.name
    end
    mother_name = common_horse.mom
    if mother_name=='' and mother = CommonHorse.find_by_sportsinfo_id(horse_attributes[:mother_id])
      mother_name = mother.name
    end

    common_horse.assign_attributes({
                                       sportsinfo_id: horse_attributes[:id],
                                       name: horse_attributes[:name],
                                       registration_number: horse_attributes[:horse_registration],
                                       birthday: "#{horse_attributes[:birth_year]}-01-01",
                                       mom: mother_name,
                                       dad: father_name,
                                       nationality: horse_attributes[:country],
                                       # There can apparently be horses with no gender.
                                       gender: horse_attributes[:gender].try(:downcase),
                                       sportsinfo_trainer_id: horse_attributes[:trainer_id]
                                   })

    common_horse.save if common_horse.changed?
  end
end
