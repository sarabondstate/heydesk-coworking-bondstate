class PushNotification < ApplicationRecord
  require 'fcm'
  belongs_to :user

  def self.add_bulk(notified_user_ids,title,msg)
    notified_user_ids.each do |user_id|
      PushNotification.create_push_notification(user_id,title,msg)
    end
  end

  def self.create_push_notification(user_id, title, message)
    notification = PushNotification.new(user_id: user_id, message: message, title: title)
    notification.save
  end

  def send_push_notification()

    # I believe we need to add stable id to PushNotifcation before we can set all options

    tokens = self.user.push_tokens.map {|t| t.token}
    unless tokens.blank?
      fcm = FCM.new(Rails.application.config.fcm_key)
      options = {}
      options[:notification] = {}
      options[:notification][:title] = self.title
      options[:notification][:body] = self.message
      options[:notification][:sound] = "default"
      #options[:notification][:badge] = 0 # Does it make sense to send this? This number only makes sense for each stable, so maybe it would be weird to send the total amount - I dunno...
      options[:content_available] = true
      options[:data] = {}
      options[:data][:id] = self.user_id
      options[:priority] = "high"
      #options[:collapse_key] = "Læs mere" # This should be translated, but to what locale? Each stable has their own locale...
      options[:data][:title] = self.title
      options[:data][:message] = self.message

      response = fcm.send(tokens, options)
      puts "response: " + response.inspect
    end
    mark_as_sent
  end

  def mark_as_sent
    self.sent = true
    self.save
  end



end
