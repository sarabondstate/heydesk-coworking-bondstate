Apipie.configure do |config|
  config.app_name                = 'MossonRails'
  config.api_base_url            = '/api'
  config.doc_base_url            = '/apipie'
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/v4/*.rb"
  config.default_version         = 'v4'

  config.app_info = 'First and foremost, when you create a session, you receive `user_credentials`. A token you should now include in every call from then on (that requires the user). It can be given as a parameter or in the header.

Common errors:
  {error: "PARAMS_MISSING"}, status: 422
  {error: "COULD_NOT_SAVE", message: e}, status: 422
  {error: "INVALID_PARAM", message: e}, status: 422
  {error: "UNAUTHORIZED"}, status: 403
  {error: "NOT_FOUND", message: e}, status: 404
  {error: "NOT_AUTHENTICATED"}, status: 401
'
end

# Eager load all validators
for validator in Dir.glob(Rails.root.join('app/apipie_validators/*'))
  load validator
end