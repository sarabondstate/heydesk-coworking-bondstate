class Api::V3::StablesController < Api::V3::ApiController
  load_and_authorize_resource

  #api! 'Show stable information'
  #example '{
  #  "id": 11,
  #  "name": "My awesome stable!"
#}'
  #def show
  #  render_for_api :basic, json: @stable
  #end
end
