class Api::V3::MyPlansController < Api::V3::ApiController
  load_and_authorize_resource :stable

  include CommonActions::HorseActions
  include CommonActions::TaskActions
  include CommonActions::UserActions
  include CommonActions::MyListActions

  api! 'Helper call to get horses, tasks, tags and my lists in one call'
  example '{"horses": [...], "tasks": [...], "my_lists": [...], "users": [...], "tags": [...]}'
  param :horse_since, String , 'Filters horses to only show those who have been updated since. You should use an `updated_at` from the latest call. Should look like 2017-08-31T07:30:21.818Z'
  param :user_since, DateTime, 'Only get updates of users'
  param :task, Hash do
    param :from_date, Date, 'Only show tasks that are after or on this date'
    param :until_date, Date, 'Only show tasks that are before this date (not included)'
    param :include_overdue, %w(true), 'Includes overdue tasks before "from_date". Should be used with "from_date".'
    param :undated, %w(true), 'Does not make sense along with "from" and "until" dates'
    param :since, DateTime, 'Filters to only show those who have been updated since. You should use an `updated_at` from the latest call. Should look like 2017-08-31T07:30:21.818Z. This will also list deleted tasks.'
  end
  def index

    #DeveloperMessage.new_message(self.class, "My plans") 
    horses = horse_index(@stable, params[:horse_since])
    #DeveloperMessage.new_message(self.class, "Done getting horses") 
    task_params = params[:task] || {}
    task_params[:stable_id] = @stable.id
    tasks = task_index(task_params)
    #DeveloperMessage.new_message(self.class, "Done getting tasks") 
    my_lists = my_lists_index(@stable, current_user)
    #DeveloperMessage.new_message(self.class, "Done getting my lists") 
    tags = @stable.tags.as_api_response(:basic)
    #DeveloperMessage.new_message(self.class, "Done getting tags") 
    users = user_index(@stable, params[:user_since])
    #DeveloperMessage.new_message(self.class, "Done getting users") 
    render json: {horses: horses, tasks: tasks, my_lists: my_lists, tags: tags, users: users}
  end
end
