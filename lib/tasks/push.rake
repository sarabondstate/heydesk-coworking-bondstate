namespace :push do
  desc "TODO"
  task process_queue: :environment do
    PushNotification.where(sent: false).each do |notif|
        notif.send_push_notification
    end
  end

end
