class Api::V4::TasksController < Api::V4::ApiController
  load_and_authorize_resource except: [:index, :tasks_with_horses, :create, :patch_multiple, :destroy_multiple, :destroy, :taggable_users, :get_mto_template]
  load_and_authorize_resource :stable, only: :create

  include CommonActions::TaskActions
  include CommonActions::HorseActions

  def_param_group :task do
    param :task, Hash, action_aware: true, required: true do
      #param :horse_ids, :array_of_ints, 'Ids of connected horses. The user should have read access to the horses.'
      param :horse_dates, Array, required: true do
        param :horse_id, :number_or_empty, required: true
        param :date, :date_or_empty, required: true
        param :completed, %w(true false), 'By default tasks are not completed.'
        param :custom_field_values_attributes, Array do
          param :custom_field_id, :number, required: true
          param :value_one, String
          param :value_two, String
        end
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
    starttime = DateTime.now
    tasks = task_index(params)
    horses = horse_index(Stable.find(params[:stable_id]), params[:horse_since])
    render json: {tasks: tasks, horses: horses}
    DeveloperMessage.new_message(self.class, "#{current_user.email}: tasks_with_horses: Done getting task_with_horses in #{DateTime.now.to_i - starttime.to_i} seconds")
  end

  api! 'Creates new tasks. Returns the newly created tasks'
  desc 'If any of the tasks is invalid, the entire POST will fail and nothing will be saved.'
  example ' The format of the task[horse_dates]:
  task[horse_dates][][horse_id]=34
  task[horse_dates][][date]=2017-10-18
  task[horse_dates][][completed]=true
  task[horse_dates][][custom_field_values_attributes][][custom_field_id]=5
  task[horse_dates][][custom_field_values_attributes][][value_one]=Commodore 64
  task[horse_dates][][custom_field_values_attributes][][custom_field_id]=2
  task[horse_dates][][custom_field_values_attributes][][value_one]=42
  task[horse_dates][][horse_id]=
  task[horse_dates][][date]=2017-10-19
  task[horse_dates][][completed]=false

  horse_id or date can be empty, but must be provided.
  '
  param_group :task
  def create
    tasks = []

    params[:task][:type_id] = TagType.find_by_title(params[:task][:type]).try(:id) unless params[:task][:type].empty?

    ActiveRecord::Base.transaction do
      params[:task][:horse_dates].each do |horse_data|
        horse_data.permit! # We are accepting all parameters we get
        tp = task_params
        tp[:stable_id] = @stable.id
        tp[:horse_id] = horse_data[:horse_id]
        tp[:date] = horse_data[:date]
        if horse_data[:completed] === 'true'
          tp[:completed_at] = horse_data[:date] +'T'+ Time.now.strftime('%H:%M:%S%z')
          tp[:completed_by] = current_user
        end
        tp[:custom_field_values_attributes] = horse_data[:custom_field_values_attributes].each {|data| data[:id] = nil} if horse_data[:custom_field_values_attributes] # Add id=nil to all fields. Rails needs them
        task = Task.new(tp)

        authorize! :create, task

        task.user = current_user
        if params[:task][:internal_note]
          task.internal_note = params[:task][:internal_note]
        end

        task.save!
        if params[:task][:task_image].present? && params[:task][:task_image][0].present?
          task.task_images.create(image: params[:task][:task_image][0])
          @media_type = task.task_images.first.image_content_type.include?("video") ? "video" : "image" rescue "no attachment"
        end
        tasks << task
      end
    end

    render json: tasks.map{|task| task.task_hash_with_extra_info(current_user, @media_type)}
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
    task.updated_by = current_user
    task.save
    render json: task.as_hash_with_extra_info(current_user)
  end

  api! 'Get details of a single task'
  example '
  {
    "id": 673,
    "horse_id": 10,
    "stable_id": 5,
    "title": "demo title",
    "completed": false,
    "completed_by": null,
    "updated_by": null,
    "completed_at": null,
    "date": null,
    "time": null,
    "note": null,
    "internal_note": null,
    "created_by": 28,
    "tag_ids": [],
    "type": "training",
    "images_lst": [],
    "created_at": "2019-03-28T10:47:03.314Z",
    "updated_at": "2019-03-28T10:47:03.314Z",
    "deleted": false,
    "custom_field_values": [],
    "write_access": true
  }
  '
  def show
    @media_type = @task.task_images.first.image_content_type.include?("video") ? "video" : "image" rescue "no attachment"
    render json: @task.task_hash_with_extra_info(current_user, @media_type)
  end

  api! 'Update a task. You can only update a task if it belongs to your stable. A trainer can update all tasks, and employees only the ones they created themselves. Returns the updated task. Also use this to complete a task, just update "completed".'
  param :task, Hash, action_aware: true, required: true do
    param :horse_id, :number_or_empty, 'Id of connected horse. The user should have read access to the horse.'
    param :title, String, required: true
    param :completed, %w(true false), 'By default tasks are not completed.'
    param :date, :date_or_empty
    param :time, :time_or_empty
    param :note, String, 'The note'
    param :tag_ids, :array_of_ints_or_empty
    param :custom_field_values_attributes, Array do
      param :id, :number, required: true
      param :custom_field_id, :number
      param :value_one, String
      param :value_two, String
      param :_destroy, %w(true false)
    end
  end
  def update

    @task.before_modify_tags
    @task.before_modify_custom_fields

    params[:task][:type_id] = TagType.find_by_title(params[:task][:type]).try(:id) if params[:task][:type] and params[:task][:type].empty? == false
    unless params[:task][:horse_id].empty?
      horse = Horse.find(params[:task][:horse_id])
      authorize! :read, horse
    end

    # Set task to completed/uncompleted if necessary
    update_params = task_params
    if @task.completed_at.nil? && params[:task][:completed] == 'true'
      update_params[:completed_at] = DateTime.now
      update_params[:completed_by] = current_user
    elsif @task.completed_at != nil && params[:task][:completed] == 'false'
      update_params[:completed_at] = nil
      update_params[:completed_by] = nil
    end
    if @task.type && (@task.type.title == 'race' || @task.type.title == 'training')
      @task.internal_note = params[:task][:internal_note]
    end
    update_params[:updated_by] = current_user
    @task.update!(update_params)

    @task.after_modify_tags
    @task.after_modify_custom_fields

    render json: @task.as_hash_with_extra_info(current_user)
  end

  api! 'Remove a task. Same permissions as update. Returns `200` on success.'
  def destroy
    @task = Task.find_by(id: params[:id])
    unless @task.nil?
      authorize! :destroy, @task
      @task.destroy
    end
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
        task.updated_by = current_user
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

  api! 'Add image as base64 string for a given task. Return 200'
  param :task, Hash, required: true do
    param :image, String, required: true
  end

  def add_image
    if(params[:id] && params[:image])
      task_img_obj = TaskImage.new(task_id: params[:id], image: params[:image])
      if task_img_obj.save
       # render json: { message: task_img_obj.thumb_url}, status: 200
       render_for_api :basic, json: task_img_obj
      end
    else
      render :json => {}, status: 400
    end
  end

  def delete_image
    if(params[:id] && params[:task_id])
      task = Task.find(params[:task_id])
      authorize! :read, task
      task_img_obj = TaskImage.find(params[:id])
      if task_img_obj.destroy
        render json: {}, status: 200
      end
    else
      render :json => {}, status: 400
    end
  end

  api! 'Get list of users in stable that are allowed to be mentioned in a feedback on a specific task'
  def taggable_users
    if params[:task_id]
      tasks = Task.where(id: params[:task_id])
      task = tasks.first
      authorize! :read, task
      taggable_users = []
      task.stable.users.each do |u|
        taggable_users.push(
            'user_id' => u.id,
            'taggable' => (::Task.select_tasks(tasks, task.stable, u).length > 0) || (check_for_emp_D(task, u)) ? true : false
        )
      end
      render :json => taggable_users, status: 200
    else
      render :json => {}, status: 400
    end

  end

  def check_for_emp_D(task, user)
    if (user.has_role_in_stable?(["employee_d"], task.stable)) && (user.user_stable_roles.first.horses.where(id: task.horse_id))
      true
    else
      false
    end
  end

  def get_mto_template
    begin
      if check_for_access?
        title = "Message to Owner"
        tag = Tag.find_by_tag_type_id(5)
        render json: {title: title, tag: tag}, status: 200
      else
        render json: {message: "You are not authorized to access this page."}, status: 400
      end
    rescue => ex
      render json: {error: ex.message}, status: 400
    end
  end

  def check_for_access?
    if current_user.is_a_trainer? || current_user.is_a_employee_a? || current_user.is_a_employee_b? || current_user.is_a_employee_c?|| current_user.is_a_employee_d?
      true
    else
      false
    end
  end

  private
  def task_params
    params.require(:task).permit(:title, :date, :type_id, :time, :note, :internal_note, :horse_id, tag_ids: [], custom_field_values_attributes:[:id, :custom_field_id, :value_one, :value_two, :_destroy])
  end
end
