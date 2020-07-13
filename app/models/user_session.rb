class UserSession < Authlogic::Session::Base
  single_access_allowed_request_types :any # Enable API access
end