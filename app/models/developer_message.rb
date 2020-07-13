class DeveloperMessage < ApplicationRecord
  def self.new_message(origin, message, job = "")
    unless job.blank?
      Rails.logger.info("#{origin}[#{job}]: #{message}")
    else
      Rails.logger.info("#{origin}: #{message}")
    end
    DeveloperMessage.create!(message: message, origin: origin, job: job)
  end
end
