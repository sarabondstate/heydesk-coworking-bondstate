class Api::V1::TasksController < Api::V1::ApiController
  load_and_authorize_resource except: [:index, :tasks_with_horses, :create, :patch_multiple, :destroy_multiple]
  load_and_authorize_resource :stable, only: :create

  include CommonActions::TaskActions
  include CommonActions::HorseActions

  def_param_group :task do
    param :task, Hash, action_aware: true, required: true do
      #param :horse_ids, :array_of_ints, 'Ids of connected horses. The user should have read access to the horses.'
      param :horse_dates, Array, required: true do
        param :horse_id, :number_or_empty, required: true
        param :date, :date_or_empty, required: true
      end
      param :title, String, required: true
      param :time, :time_or_empty
      param :note, String, 'The note'
      param :tag_ids, :array_of_ints_or_empty
      param :type, TagType.all.pluck(:title), 'The type of task', required: true
    end
  end

  api! 'Lists all tasks associated with a specific horse or stable. By default it will not list deleted tasks, unless you provide "since".'
  param :from_date, Date, 'Only show tasks that are after or on this date'
  param :until_date, Date, 'Only show tasks that are before this date (not included)'
  param :include_overdue, %w(true), 'Includes overdue tasks before "from_date". Should be used with "from_date".'
  param :undated, %w(true), 'Does not make sense along with "from" and "until" dates'
  param :since, DateTime, 'Filters to only show those who have been updated since. You should use an `updated_at` from the latest call. Should look like 2017-08-31T07:30:21.818Z. This will also list deleted tasks.'
  example '[
    {
        "id": 255,
        "horse_id": null,
        "stable_id": 17,
        "title": "Motion",
        "completed": false,
        "date": "2013-02-04",
        "time": "23:00",
        "note": null,
        "created_by": 66,
        "tag_ids": [
            1,
            4
        ],
        "type": "training",
        "created_at": "2017-09-06T09:03:56.002Z",
        "updated_at": "2017-09-06T11:18:42.422Z",
        "deleted": true,
        "write_access": true
    }
]'
  def index
    tasks = task_index(params)
    render json: tasks
  end

  api! 'A copy of task index. Only difference is in this call you also get horses.'
  param :from_date, Date, 'Only show tasks that are after or on this date'
  param :until_date, Date, 'Only show tasks that are before this date (not included)'
  param :include_overdue, %w(true), 'Includes overdue tasks before "from_date". Should be used with "from_date".'
  param :undated, %w(true), 'Does not make sense along with "from" and "until" dates'
  param :since, DateTime, 'Filters to only show those who have been updated since. You should use an `updated_at` from the latest call. Should look like 2017-08-31T07:30:21.818Z. This will also list deleted tasks.'
  param :horse_since, String, 'Filters horses to only show those who have been updated since. You should use an `updated_at` from the latest call. Should look like 2017-08-31T07:30:21.818Z'
  example '{tasks: [...tasks...], horses: [...horses...]}'
  #see 'tasks#index', 'tasks index for more documentation'
  def tasks_with_horses
    tasks = task_index(params)
    horses = horse_index(Stable.find(params[:stable_id]), params[:horse_since])
    render json: {tasks: tasks, horses: horses}
  end

  api! 'Creates new tasks. Returns the newly created tasks'
  desc 'If any of the tasks is invalid, the entire POST will fail and nothing will be saved.'
  example ' The format of the task[horse_dates]:
  task[horse_dates][][horse_id]=34
  task[horse_dates][][date]=2017-10-18
  task[horse_dates][][horse_id]=
  task[horse_dates][][date]=2017-10-19

  horse_id or date can be empty, but must be provided.
  '
  param_group :task
  def create
    tasks = []
    params[:task][:type_id] = TagType.find_by_title(params[:task][:type]).try(:id) unless params[:task][:type].empty?
    ActiveRecord::Base.transaction do
      params[:task][:horse_dates].each do |horse_date|
        tp = task_params
        tp[:stable_id] = @stable.id
        tp[:horse_id] = horse_date[:horse_id]
        tp[:date] = horse_date[:date]
        task = Task.new(tp)

        authorize! :create, task

        task.user = current_user

        task.save!
        tasks << task
      end
    end

    render json: tasks.map{|task| task.as_hash_with_extra_info(current_user)}
  end

  api! 'Complete a task.'
  param :uncomplete, %w(true), '"Uncompletes" task. Marks it as uncomplete.'
  def complete
    task = Task.find(params[:task_id])
    authorize! :complete, task
    task.completed_at = DateTime.now
    task.completed_by = current_user
    if params[:uncomplete]=='true'
      task.completed_at = nil
      task.completed_by = nil
    end
    task.save
    render json: task.as_hash_with_extra_info(current_user)
  end

  #api! 'Get details of a single task'
  #def show
  #  render json: @task.as_hash_with_extra_info(current_user)
  #end

  api! 'Update a task. You can only update a task if it belongs to your stable. A trainer can update all tasks, and employees only the ones they created themselves. Returns the updated task. Also use this to complete a task, just update "completed".'
  param :task, Hash, action_aware: true, required: true do
    param :horse_id, :number_or_empty, 'Id of connected horse. The user should have read access to the horse.'
    param :title, String, required: true
    param :completed, %w(true false), 'By default tasks are not completed.'
    param :date, :date_or_empty
    param :time, :time_or_empty
    param :note, String, 'The note'
    param :tag_ids, :array_of_ints_or_empty
  end
  def update
    params[:task][:type_id] = TagType.find_by_title(params[:task][:type]).try(:id) if params[:task][:type] and params[:task][:type].empty? == false
    unless params[:task][:horse_id].empty?
      horse = Horse.find(params[:task][:horse_id])
      authorize! :read, horse
    end
    params[:task][:completed] = params[:task][:completed]=='true' if params[:task][:completed]
    @task.update!(task_params)
    render json: @task.as_hash_with_extra_info(current_user)
  end

  api! 'Remove a task. Same permissions as update. Returns `200` on success.'
  def destroy
    @task.destroy
    render json: {}, status: 200
  end

  api! 'Update multiple tasks at once'
  desc 'If an update fails, all will fail.'
  param :task_ids, :array_of_ints, required: true
  param :task, Hash, required: true do
    param :title, String
    param :time, :time_or_empty
    param :note, String, 'The note'
    param :tag_ids, :array_of_ints_or_empty
  end
  def patch_multiple
    tasks = []
    ActiveRecord::Base.transaction do
      params[:task_ids].each do |task_id|
        task = Task.find(task_id)
        authorize! :update, task
        task.update!(task_params)
        tasks << task
      end
    end

    render json: tasks.map{|task| task.as_hash_with_extra_info(current_user)}
  end

  api! 'Destroy multiple tasks at once'
  desc 'If any destroy fails, nothing will change. Return 200 on success'
  param :task_ids, :array_of_ints, required: true
  def destroy_multiple
    ActiveRecord::Base.transaction do
      params[:task_ids].each do |task_id|
        task = Task.find(task_id)
        authorize! :destroy, task
        task.destroy!
      end
    end
    render json: {}, status: 200
  end

  private
  def task_params
    params.require(:task).permit(:title, :date, :type_id, :time, :note, :horse_id, tag_ids: [])
  end
end
