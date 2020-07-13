class Api::V2::NotificationsController < Api::V2::ApiController
  load_and_authorize_resource :stable

  include CommonActions::UserActions
  include CommonActions::HorseActions

  api! 'Lists all comments associated with a task.'
  param :limit, :number, 'Limit number of notification results. Default is 50.'
  param :user_since, DateTime, 'Only get updates of users'
  param :horse_since, String , 'Filters horses to only show those who have been updated since. You should use an `updated_at` from the latest call. Should look like 2017-08-31T07:30:21.818Z'
  example '{tasks: [...], comments: [...], horses: [...], users: [...], tags: [...]}'
  def index
    notifications = current_user.notifications.where(stable: @stable).order(updated_at: :desc)
    limit = params[:limit] || 50
    notifications = notifications.limit(limit)
    notification_objects = {}
    notifications.each do |notification|
      object = notification.notifiable
      notification_objects[object.class.to_s.downcase.pluralize] = [] unless notification_objects.include?(object.class.to_s.downcase.pluralize)
      if object.is_a?(Task)
        notification_objects[object.class.to_s.downcase.pluralize] << object.as_hash_with_extra_info(current_user)
      else
        notification_objects[object.class.to_s.downcase.pluralize] << object.as_api_response(:basic)
      end
    end

    notification_objects[:users] = user_index(@stable, params[:user_since])
    notification_objects[:horses] = horse_index(@stable, params[:horse_since])
    notification_objects[:tags] = @stable.tags.as_api_response(:basic)

    render json: notification_objects
  end
end
