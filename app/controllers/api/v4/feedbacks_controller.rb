class Api::V4::FeedbacksController < Api::V4::ApiController
  load_and_authorize_resource :stable

  include CommonActions::UserActions
  include CommonActions::HorseActions

  api! 'Lists all comments associated with a task.'
  param :limit, :number, 'Limit number of feedback results. Default is 50.'
  param :user_since, DateTime, 'Only get updates of users'
  param :horse_since, String , 'Filters horses to only show those who have been updated since. You should use an `updated_at` from the latest call. Should look like 2017-08-31T07:30:21.818Z'
  example '{tasks: [...], comments: [...], horses: [...], users: [...], tags: [...]}'
  def index
    active_horse_feedback_ids = []

    limit = 100
    all_feedbacks = current_user.feedbacks.where(stable: @stable).includes(:read_feedbacks).order(:id)

    # Check if feedback horse exists and is active
    all_feedbacks.each do |f|
      task = f.notifiable
      if f.notifiable.is_a?(Comment)
        task = f.notifiable.task
      end

      if task.horse && task.horse.active
        active_horse_feedback_ids << f.id
      end
    end

    all_feedbacks = all_feedbacks.where(id: active_horse_feedback_ids).order(:id)

    # Find oldest unread feedback
    oldest_unread = nil
    all_feedbacks.each do |f|
      if f.read_feedbacks.where(user_id: current_user.id).count() == 0
        oldest_unread = f
        break
      end
    end

    if !oldest_unread.nil?

      # We successfully found the oldest unread feedback. Fetch all feedbacks since that one.
      feedbacks = all_feedbacks.where('feedbacks.id >= ?', oldest_unread.id).order(updated_at: :desc)

      # If feedbacks are less then limit, then fetch limit
      if feedbacks.count() < limit
        feedbacks = all_feedbacks.order(updated_at: :desc).limit(limit)
      end

    else
      # We did not find any unread feedbacks. Just load the last 100 feedbacks
      feedbacks = all_feedbacks.order(updated_at: :desc).limit(limit)
    end

    feedback_objects = {}
    feedbacks.each do |feedback|
      object = feedback.notifiable
      feedback_objects[object.class.to_s.downcase.pluralize] = [] unless feedback_objects.include?(object.class.to_s.downcase.pluralize)
      if object.is_a?(Task)
        final_object = object.as_hash_with_extra_info(current_user)
      elsif object.is_a?(Comment)
        # If feedback is a comment we add the corresponding task to the response if it has not already been added
        final_object = object.as_api_response(:basic)
        feedback_objects[Task.to_s.downcase.pluralize] = [] unless feedback_objects.include?(Task.to_s.downcase.pluralize)
        feedback_objects[Task.to_s.downcase.pluralize] << object.task.as_api_response(:basic) unless feedback_objects[Task.to_s.downcase.pluralize].include?(object.task)
      else
        final_object = object.as_api_response(:basic)
      end

      final_object[:read] = feedback.read_feedbacks.where(user_id: current_user.id).count() != 0

      feedback_objects[object.class.to_s.downcase.pluralize] << final_object

    end
    # feedback_objects[:tasks] =[]
    feedback_objects[:users] = user_index(@stable, params[:user_since])
    feedback_objects[:horses] = horse_index(@stable, params[:horse_since])
    feedback_objects[:tags] = @stable.tags.includes(:tag_type).as_api_response(:basic)

    render json: feedback_objects
  end

  api! 'Mark a single feedback as read.'
  param :feedback_id, :number, 'Id of the feedback'
  def read_feedback

    # The id being sent from the device is that objects id, current the feedback tab only shows comments, so the id is the comments id
    feedback = current_user.feedbacks.where(stable: @stable, notifiable_type: "Comment", notifiable_id: params[:id]).first

    begin
      mark_as_read feedback
    rescue Exception
      render json: {}, status: 500
      return
    end

    render json: {message: "done"}, status: 200

  end

  api! 'Mark all feedbacks of a specific task type as read.'
  param :type, String, 'Task type to make as read'
  def read_all_feedbacks

    feedbacks = current_user.feedbacks.where(stable: @stable).left_outer_joins(:read_feedbacks).where(:read_feedbacks => {user_id: nil})

    ActiveRecord::Base.transaction do

      feedbacks.each do |feedback|
        begin

          # Check if feedback matches the type of task, otherwise skip
          object = feedback.notifiable
          if object.is_a?(Task) && object.type.title != params[:type]
            next
          elsif object.is_a?(Comment) && object.task.type.title != params[:type]
            next
          end

          mark_as_read feedback
        rescue Exception
          render json: {}, status: 500
          raise ActiveRecord::Rollback
        end
      end

    end

    render json: {}, status: 200

  end

  private
  # Marks feedback as read.
  # Will raise an exception if not successful (if feedback was previously marked as read, then it is considered successful)
  def mark_as_read(feedback)
    begin
      ReadFeedback.create([{ :user_id => current_user.id, :feedback_id => feedback.id }])
    rescue Exception => ex
      if ex.class == ActiveRecord::RecordNotUnique
        # It appears that we already marked this feedback as read, oh well
      elsif
       raise ex
      end
    end

  end

end
