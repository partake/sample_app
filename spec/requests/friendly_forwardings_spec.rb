require 'spec_helper'

describe "FriendlyForwardings" do
  it "should forward to the requested page of signin" do
    user = Factory(:user)

		visit edit_user_path(user)
		fill_in :email, :with => user.email
		fill_in :password, :with => user.password
		click_button
 		response.should render_template('users/edit')

		visit signout_path
		response.should have_selector('title', :content => "Home")

		visit signin_path(user)
		fill_in :email, :with => user.email
		fill_in :password, :with => user.password
		click_button
 		response.should render_template('users/show')

  end

end
