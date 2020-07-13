module CommonActions

  module TaskActions

    include TaskHelper
    ##
    # Returns tasks in stable.
    def task_index(params)
      from_date = params[:from_date] || 14.days.ago.beginning_of_day

      # Two entries, one through stables and one through horses.
      starttime = DateTime.now
      tasks = Task.all
      tasks = tasks.includes(:tags, :custom_field_values)
      tasks = tasks.where('date >= ?', from_date)
      tasks = tasks.where('date < ?', params[:until_date]) if params[:until_date]
      tasks = tasks.or(Task.where('date < ?', params[:from_date]).where(completed: false)) if params[:from_date] and params[:include_overdue]
      tasks = tasks.where(date: nil) if params[:undated]
      #DeveloperMessage.new_message(self.class, "Tasks wheres done")
      # These checks should below the "or" above, or else the "or" will fail.

      unless params[:stable_id].nil?
        stable = Stable.find(params[:stable_id])
        authorize! :read, stable
        tasks = tasks.where(stable: stable)
      end
      #DeveloperMessage.new_message(self.class, "Stable part")
      unless params[:horse_id].nil?
        horse = Horse.find(params[:horse_id])
        authorize! :read, horse
        tasks = tasks.where(horse: horse)
      end
      #DeveloperMessage.new_message(self.class, "Horse part")
      tasks = tasks.with_deleted.where('tasks.updated_at > ?', params[:since]) if params[:since]
      if tasks.count > 0
        tasks = limit_tasks(tasks, tasks.first.stable)
      end

      #DeveloperMessage.new_message(self.class, "date Constraints done")
      DeveloperMessage.new_message(self.class, "task_index: Done doing query stuff, took #{DateTime.now.to_i - starttime.to_i} seconds")
      DeveloperMessage.new_message(self.class, "task_index: Beging rendering as api")
      starttime = DateTime.now
      response = tasks.as_api_response(:basic_for_my_plan)
      DeveloperMessage.new_message(self.class, "task_index: done rendering as api, took #{DateTime.now.to_i - starttime.to_i} seconds")
      return response
      #tasks.map do |task|
      #  task.as_hash_with_extra_info(current_user)
      #end
    end


  end
end
