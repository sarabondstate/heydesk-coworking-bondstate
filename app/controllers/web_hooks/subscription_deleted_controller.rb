class WebHooks::SubscriptionDeletedController < ActionController::Base

  def run
    # Call must be made with this parameter
    if params[:auth] != 'o2Bjgl_7FJKcZTehb3lR:dOe894AdX1pVQe4ExRwsLCJChyIegK3aDclWjFOXmjG38le6tz'
      DeveloperMessage.new_message(self.class, "Not authenticated:" + params.inspect)
      return
    end

    event_json = JSON.parse(request.body.read, object_class: OpenStruct)
    if event_json.type != 'customer.subscription.deleted'
      # We only allow this specific type of events
      head :method_not_allowed
      return
    end

    # Everything appears to be in order, get customer from db
    customer = User.where(stripe_id: event_json.data.object.customer).first

    # Set all stable where customer is trainer as inactive
    customer.trainer_stables.each do |s|
      s.active = false
      s.plan_id = nil
      s.save
    end

    head :ok

  end
end
