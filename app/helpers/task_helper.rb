module TaskHelper

  def limit_tasks(tasks, stable)
    starttime = DateTime.now
    DeveloperMessage.new_message(self.class, "limit tasks start")
    tasks = Task.select_tasks(tasks, stable, current_user)
    DeveloperMessage.new_message(self.class, "limit tasks end, took #{DateTime.now.to_i - starttime.to_i} seconds")
    tasks
  end

end
