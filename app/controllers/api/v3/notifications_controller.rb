class Api::V3::NotificationsController < Api::V3::ApiController
  load_and_authorize_resource :stable

  include CommonActions::UserActions
  include CommonActions::HorseActions

  api! 'Lists all comments associated with a task.'
  param :limit, :number, 'Limit number of feedback results. Default is 50.'
  param :user_since, DateTime, 'Only get updates of users'
  param :horse_since, String , 'Filters horses to only show those who have been updated since. You should use an `updated_at` from the latest call. Should look like 2017-08-31T07:30:21.818Z'
  example '{tasks: [...], comments: [...], horses: [...], users: [...], tags: [...]}'
  def index

    limit = 100
    all_feedbacks = current_user.feedbacks.where(stable: @stable).left_outer_joins(:read_feedbacks).select("feedbacks.*, (read_feedbacks.user_id IS NOT NULL) as read")

    oldest_unread = all_feedbacks.map(&:attributes).delete_if{|x| x['read']}.sort_by {|value| value['id'] }.first
    if oldest_unread

      # We successfully found the oldest unread notification. Fetch all notifications since that one.
      feedbacks = all_feedbacks.where('feedbacks.id >= ?', oldest_unread['id']).order(updated_at: :desc)

      # If notifications are less then limit, then fetch limit
      # HACK: Had to do to_a, because SQL query fails when using count()-method because of select()-statement. Better solution always appreciated!
      if feedbacks.to_a.count() < limit
        feedbacks = all_feedbacks.order(updated_at: :desc).limit(limit)
      end

    else
      # We did not find any unread notifications. Just load the last 100 notifications
      feedbacks = all_feedbacks.order(updated_at: :desc).limit(limit)
    end

    feedback_objects = {}
    feedbacks.each do |feedback|
      object = feedback.notifiable
      feedback_objects[object.class.to_s.downcase.pluralize] = [] unless feedback_objects.include?(object.class.to_s.downcase.pluralize)
      if object.is_a?(Task)
        final_object = object.as_hash_with_extra_info(current_user)
      else
        final_object = object.as_api_response(:basic)
      end

      final_object[:read] = feedback.read
      feedback_objects[object.class.to_s.downcase.pluralize] << final_object

    end

    feedback_objects[:users] = user_index(@stable, params[:user_since])
    feedback_objects[:horses] = horse_index(@stable, params[:horse_since])
    feedback_objects[:tags] = @stable.tags.as_api_response(:basic)

    render json: feedback_objects
  end

  api! 'Mark a single feedback as read.'
  param :feedback_id, :number, 'Id of the feedback'
  def read_notification

    feedback = current_user.feedbacks.where(stable: @stable).find(params[:id])

    begin
      mark_as_read feedback
    rescue Exception
      render json: {}, status: 500
      return
    end

    render json: {}, status: 200

  end

  api! 'Mark all feedbacks of a specific task type as read.'
  param :type, String, 'Task type to make as read'
  def read_all_notifications

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
