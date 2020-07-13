require 'test_helper'

class OccupancyControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get occupancy_index_url
    assert_response :success
  end

end
