class CookiesController < ApplicationController
  skip_before_action :check_terms_accepted_and_logged_in

  def index
  end

end
