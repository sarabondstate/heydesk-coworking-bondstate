require 'test_helper'

class AddDetailControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get add_detail_index_url
    assert_response :success
  end

end
