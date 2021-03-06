class Api::V2::CommentsController < Api::V2::ApiController
  load_and_authorize_resource :task, only: [:index, :create]
  load_and_authorize_resource except: [:index, :create]

  include CommonActions::UserActions

  api! 'Lists all comments associated with a task.'
  param :since, DateTime, 'Only show new comments since. You should use an `updated_at` from the latest call.'
  param :user_since, DateTime, 'Only get updates of users'
  example '{
  "comments": [{
        "id": 30,
        "text": "Wow [u=148]@Employee Gut 3[/u]. Tak",
        "task_id": 262,
        "created_by": 144,
        "tag_ids": [
          133
        ],
        "task_type": "todo",
        "tagged_users": [
            {
                "id": 148,
                "name": "Employee Gut 3"
            }
        ],
        "created_at": "2017-10-09T07:35:36.815Z",
        "updated_at": "2017-10-09T07:35:36.815Z"
    }],
  "users": [...]
}'
  def index
    comments = @task.comments

    comments = comments.where('comments.updated_at > ?', params[:since]) if params[:since]
    comments = comments.as_api_response(:basic)

    users = user_index(@task.stable, params[:user_since])

    render json: {comments: comments, users: users}
  end

  api! 'Creates a new comment. Returns the newly created comment'
  param :comment, Hash, required: true do
    param :text, String, required: true
    param :tag_ids, :array_of_ints
  end
  def create
    comment = Comment.new(comment_params)
    comment.task = @task

    authorize! :create, comment

    comment.user = current_user
    comment.save!

    render_for_api :basic, json: comment
  end

  #api! 'Get details of a single comment'
  #def show
  #  render_for_api :basic, json: @comment
  #end

  private
  def comment_params
    params.require(:comment).permit(:text, tag_ids: [])
  end
end
