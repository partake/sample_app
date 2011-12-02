require 'spec_helper'

describe SessionsController do
  render_views

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end # successful
    it "should have the right title" do
      get :new
      response.should have_selector('title', :content => "Sign in")
    end # right title
  end # Get 'new'

  describe "POST 'create'" do
   describe "failure" do
     before (:each) do
       @attr = {:email =>"", :password => ""}
     end # each
     it "should re-render the new session page" do
       post :create, :session => @attr
       response.should render_template('new')
     end # re-render
     it "should have the right title" do
       post :create, :session => @attr
       response.should have_selector('title', :content =>"Sign in")   
     end
     it "should have an error message" do
       post :create, :session => @attr
       flash.now[:error].should =~ /invalid email\/password combination/i
     end
   end # failure
 end # POST

end # SessionController
