module ModelNotifies
  # This module enriches the ActiveRecord::Base module of Rails.
  module Base
    ##
    # This creates Feedbacks for the list of `users`.
    # If one should not be notified (usually the creator), provide the user
    # The provided parameters will be run on the object
    # A block can be given where you can return true or false to define is it should notify or not
    def model_notifies(users, but_dont_notify = nil)
      class_eval do
        after_destroy do
          # Find Feedbacks and destroy them
          ::Feedback.where(notifiable: self).destroy_all
        end

        after_create do
          # If a block exists we should only continue if it returns true
          if block_given? == false or (block_given? && yield(:create, self))
            # Get stable
            stable_id = self.try(:stable_id)
            stable_id ||= self.try(:task).try(:stable_id)

            unless stable_id.nil?
              stable_obj = ::Stable.find(stable_id)
              dont_notify_id = but_dont_notify.nil? ? [] : [self.instance_eval(but_dont_notify).try(:id)]
              user_ids = self.instance_eval(users).pluck(:id)
              user_ids -= dont_notify_id

              #saving the push notifications
              horse_obj = self.is_a?(::Comment) ? self.task.horse : self.horse
              title = ""
              msg = ""

              if self.is_a?(::Comment)
                title = I18n.t('Notification.feedback_title', locale: stable_obj.locale.to_sym)
                msg = horse_obj ? I18n.t('Notification.feedback_msg2', :task_name=> self.task.title, :horse_name=> horse_obj.common_horse.name, locale: stable_obj.locale.to_sym) : I18n.t('Notification.feedback_msg1', :task_name=> self.task.title, locale: stable_obj.locale.to_sym)
              else
                title = I18n.t('Notification.observation_title', locale: stable_obj.locale.to_sym)
                msg = horse_obj ? I18n.t('Notification.observation_msg2', :observation_name=> self.title, :horse_name=> horse_obj.common_horse.name, locale: stable_obj.locale.to_sym) : I18n.t('Notification.observation_msg1', :observation_name=> self.title, locale: stable_obj.locale.to_sym)
              end

              msg = msg.gsub(/(\[u=\d+\])|\[\/u\]/,'') #ActionController::Base.helpers.strip_tags(msg)

              notified_user_ids = []
              feedback_user_ids = []
              if self.is_a?(::Comment)
                #tagged users #find if the tagged user should  C any comment related to task and tags
                user_ids.each do |user_id|
                  @user = ::User.find(user_id)
                  role = @user.user_stable_roles.where(stable: stable_obj).first
                  if role.role == "employee_d"
                    user_selected = ::Task.select_tasks_for_empD(Task.where(id: self.task.id), stable_obj, @user).length > 0 ? true : false
                  else
                    user_selected = ::Task.select_tasks(Task.where(id: self.task.id), stable_obj, @user).length > 0 ? true : false
                  end
                  if user_selected
                    notified_user_ids << user_id if @user.push_enabled && @user.push_feedback_mention
                    feedback_user_ids << user_id
                  end
                end

                #stable trainers
                stable_trainers = ::User.current_stable_trainers(stable_obj)
                stable_trainers -= dont_notify_id
                stable_trainers -= user_ids
                if stable_trainers.length
                  stable_trainers.each do |user_id|
                    @user = ::User.find(user_id)
                    notified_user_ids << user_id if @user.push_enabled && @user.push_all_horse_feedback
                    feedback_user_ids << user_id
                  end
                end

                #stable_employee_flagged_horses
                stable_employees = ::User.current_stable_employees(stable_obj)
                stable_employees -= dont_notify_id
                stable_employees -= user_ids
                if stable_employees.length
                  stable_employees.each do |user_id|
                    if horse_obj && ::HorseFlag.where(horse_id: horse_obj.id, user_id: user_id).length > 0 ? true : false
                      @user = ::User.find(user_id)
                      role = @user.user_stable_roles.where(stable: stable_obj).first
                      if role.role == "employee_d"
                        user_selected = ::Task.select_tasks_for_empD(Task.where(id: self.task.id), stable_obj, @user).length > 0 ? true : false
                      else
                        user_selected = ::Task.select_tasks(Task.where(id: self.task.id), stable_obj, @user).length > 0 ? true : false
                      end

                      if user_selected
                        notified_user_ids << user_id if @user.push_enabled && @user.push_flagged_horse_feedback
                        feedback_user_ids << user_id
                      end
                    end
                  end
                end
              # case tasks
              else
                user_ids.each do |user_id|
                  @user = ::User.find(user_id)
                  if @user.is_trainer_in_stable?(stable_obj)
                    notified_user_ids << user_id if @user.push_enabled && @user.push_all_horse_observation
                    feedback_user_ids << user_id
                  elsif !@user.is_trainer_in_stable?(stable_obj) && horse_obj && ::HorseFlag.where(horse_id: horse_obj.id, user_id: user_id).length > 0
                    role = @user.user_stable_roles.where(stable: stable_obj).first
                    if role.role == "employee_d"
                      user_selected = ::Task.select_tasks_for_empD(Task.where(id: self.id), stable_obj, @user).length > 0 ? true : false
                    else
                      user_selected = ::Task.select_tasks(Task.where(id: self.id), stable_obj, @user).length > 0 ? true : false
                    end
                    if user_selected
                      notified_user_ids << user_id if @user.push_enabled && @user.push_flagged_horse_observation
                      feedback_user_ids << user_id
                    end
                  end
                end

              end

              ::Feedback.add_bulk(feedback_user_ids,self, stable_id)
              ::PushNotification.add_bulk(notified_user_ids,title,msg)

            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.extend ModelNotifies::Base
