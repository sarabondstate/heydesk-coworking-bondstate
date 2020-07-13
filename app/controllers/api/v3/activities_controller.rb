class Api::V3::ActivitiesController < Api::V3::ApiController
  load_and_authorize_resource :horse, only: :index

  include TaskHelper
  include CommonActions::UserActions
  include CommonActions::HorseActions

  api! 'A horses "activities"'
  param :limit, :number, 'Limit number of comments and tasks combined. Default is 50.'
  param :user_since, DateTime, 'Only get updates of users'
  param :horse_since, DateTime, 'Only get updates of horses'
  desc 'This includes a horses completed tasks and comments on a horses tasks'
  example '{"comments": [...], "tasks": [...], "horses": [...], "users": [...], "tags": [...]}'
  def index
    limit = params[:limit] || 50
    limit = limit.to_i

    # Tasks related to horse
    all_tasks_for_horse = Task.where(horse: @horse)
    all_tasks_for_horse = limit_tasks(all_tasks_for_horse, @horse.stable)

    # Comments for the horses tasks
    comments = Comment.where(task: all_tasks_for_horse).order(created_at: :desc).limit(limit).to_a
    # Tasks that are completed
    tasks = Task.where(horse: @horse).where.not(completed_at: nil).order(completed_at: :desc).limit(limit)
    tasks = limit_tasks(tasks, @horse.stable)

    tasks = tasks.map do |task|
      task.as_hash_with_extra_info(current_user)
    end

    objects = {
        comments: [],
        tasks: [],
        users: user_index(@horse.stable, params[:user_since]),
        horses: horse_index(@horse.stable, params[:horse_since]),
        tags: @horse.stable.tags.as_api_response(:basic)
    }
    (1..limit).each do
      if tasks.empty? or ((comments.first and tasks.first) and comments.first.try(:created_at) > tasks.first[:completed_at])
        objects[:comments] << comments.shift.as_api_response(:basic) if comments.first
      else
        objects[:tasks] << tasks.shift if tasks.first
      end
    end

    render json: objects
  end

  api! 'Current users activities'
  param :limit, :number, 'Limit number of comments and tasks combined. Default is 50.'
  param :user_since, DateTime, 'Only get updates of users'
  param :horse_since, DateTime, 'Only get updates of horses'
  desc 'This includes your completed tasks and comments'
  example '{comments: [...], tasks: [...], users: [...], horses: [...], tags: [...]}'
  def my_activities
    stable = Stable.find(params[:stable_id])
    authorize! :read, stable

    limit = params[:limit] || 50
    limit = limit.to_i

    tasks = Task.where(stable: stable.id, completed_by_id: current_user.id).order(completed_at: :desc).limit(limit)
    tasks = limit_tasks(tasks, stable)

    tasks = tasks.map do |task|
      task.as_hash_with_extra_info(current_user)
    end

    comments = current_user.comments.where(task_id: tasks.pluck(:id)).order(created_at: :desc).limit(limit).to_a

    objects = {
        comments: [],
        tasks: [],
        users: user_index(stable, params[:user_since]),
        horses: horse_index(stable, params[:horse_since]),
        tags: stable.tags.as_api_response(:basic)
    }
    (1..limit).each do
      if tasks.empty? or ((comments.first and tasks.first) and comments.first.try(:created_at) > tasks.first[:completed_at])
        objects[:comments] << comments.shift.as_api_response(:basic) if comments.first
      else
        objects[:tasks] << tasks.shift if tasks.first
      end
    end

    render json: objects
  end
end
