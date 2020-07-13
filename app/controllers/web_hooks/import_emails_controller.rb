class WebHooks::ImportEmailsController < ActionController::Base
  def run
    # Call must be made with this parameter
    if params[:auth]!='o2Bjgl_7FJKcZTehb3lR:dOe894AdX1pVQe4ExRwsLCJChyIegK3aDclWjFOXmjG38le6tz'
      DeveloperMessage.new_message(self.class, "Not authenticated:" + params.inspect)
      return
    end
    return
    # Removed stuff - now moved to task
  end
end
