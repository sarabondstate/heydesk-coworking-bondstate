class Api::V4::TaskLogsController < Api::V4::ApiController
  load_and_authorize_resource :task, only: [:index]
  load_and_authorize_resource except: [:index]

  include CommonActions::UserActions

  api! 'Lists all logs associated with a task.'
  param :since, DateTime, 'Only show new comments since. You should use an `updated_at` from the latest call.'
  param :user_since, DateTime, 'Only get updates of users'
  example '{
  "task_logs": [{
        "id": 1,
        "user_id": 123,
        "task_id": 321,
        "key": "title", (possible values: title, note, date, time, completion, horse, tags, custom_field1, custom_field2)
        "from": "Galop",
        "to": "Trav",
        "custom_name": null, (only set if key is custom_field1 or custom_field2)
        "created_at": "2017-10-09T07:35:36.815Z",
        "updated_at": "2017-10-09T07:35:36.815Z"
    }],
  "users": [...]
}'
  def index
    logs = @task.task_logs

    logs = logs.where('task_logs.updated_at > ?', params[:since]) if params[:since]
    logs = logs.as_api_response(:basic)

    users = user_index(@task.stable, params[:user_since])

    render json: {task_logs: logs, users: users}
  end

end
