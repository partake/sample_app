require 'spec_helper'

describe UsersController do
  render_views

describe "GET 'index'" do

	describe "For non-signed in users" do
		it "should deny access" do
			get :index
			response.should redirect_to(signin_path)
		end
	end

	describe "For signed-in users" do 
		before(:each) do
			@user = test_sign_in(Factory(:user))
			second = Factory(:user, :name => "Bob", :email => "another@example.com")
			third  = Factory(:user, :name => "Ben", :email => "another@example.net")
			@users = [@user, second, third]
			30.times do
          @users << Factory(:user, :name => Factory.next(:name),
                                   :email => Factory.next(:email))
      end
		end		
		it "should be successful" do
			get :index
			response.should be_success
		end
		it "should have the right title" do
			get :index
			response.should have_selector('title', :content => "All users")
		end
		it "should have an element for each user" do
			get :index
			User.paginate(:page => 1).each do |user|
				response.should have_selector("li", :content => user.name)
			end
		end

    it "should paginate users" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
#       response.should have_selector("a", :href => "/users?page=2",
#                                           :content => "2")
#        response.should have_selector("a", :href => "/users?page=2",
#                                          :content => "Next")
    end # "should paginate users"

		it "should have delete links for admins" do
			@user.toggle!(:admin)
			other_user = User.all.second
			get :index
			response.should have_selector('a', :href => user_path(other_user), 
																							:content => "delete")
		end

		it "should not have a delete link for non-admins" do
			other_user = User.all.second
			get :index
			response.should_not have_selector('a', :href => user_path(other_user), 
																							:content => "delete")
		end


	end # "for signed users"
end # "GET 'index'"


  describe "GET 'show'" do   # Success

    before(:each) do
      @user = Factory(:user)
    end

    it "should be successful" do
      get :show, :id => @user.id
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end

    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector('title', :content => @user.name)
    end

    it "should have the user's name" do
      get :show, :id => @user
      response.should have_selector('h1', :content => @user.name)
    end

    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector('h1>img', :class => "gravatar")
    end

    it "should have the right URL" do
      get :show, :id => @user
      response.should have_selector('td>a', :content => user_path(@user),
					    :href    => user_path(@user))
    end
    it "should show users microposts" do
      mp1 = Factory(:micropost, :user => @user, :content => "Foo bar")
      mp2 = Factory(:micropost, :user => @user, :content => "Foo2 bar")
      get :show, :id => @user
	    response.should have_selector('span.content', :content => mp1.content)
	    response.should have_selector('span.content', :content => mp2.content)
    end
    it "should paginate microposts" do
      35.times {Factory(:micropost, :user => @user, :content => "foo")}
      get :show, :id => @user
      response.should have_selector("div.pagination")
    end
    it "should disply micropost counts" do
      10.times {Factory(:micropost, :user => @user, :content => "foo")}
      get :show, :id => @user
      response.should have_selector('td.sidebar', 
                                     :content => @user.microposts.count.to_s)
    end

    describe "when signed in as another user" do
      it "should be successful" do
        test_sign_in(Factory(:user, :email => Factory.next(:email)))
        get :show, :id => @user
        response.should be_success
      end
    end

  end

  describe "GET 'new'" do  # Success

    it "should be successful" do
      get :new
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Sign up")
    end
  end

  describe "POST 'create'" do  # Success
    describe "failure" do
      before (:each) do
        @attr = { :name =>"", :email =>"", :password =>"",
					   :password_confirmation => ""}
      end      
      it "should have the right title" do
        post :create, :user => @attr
	response.should have_selector("title", :content => "Sign up")
      end
      it "should render the 'new' page" do
        post :create, :user => @attr
	response.should render_template('new')
      end

      it "should not create a user" do
	lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

    end
    describe "success" do
     before (:each) do
        @attr = { :name =>"New User", :email =>"user@example.com", 
		  :password => "foobar",   :password_confirmation => "foobar"}
      end      
      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end
      it "should redirect to the user show page" do
         post :create, :user => @attr
	 response.should redirect_to(user_path(assigns(:user)))
      end

      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /welcome/i
      end

      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in    
      end
  
    end
  end

  describe "GET 'edit'" do  
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end
    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector('title', :content => "Edit user")
    end
    it "should have a link to change the Gravatar" do
      get :edit, :id => @user
      response.should have_selector('a', :href => 'http://gravatar.com/emails',
					:content => "change")   
    end
  end
  describe "PUT (edit) 'update'" do
    before() do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    describe "failure" do
      before (:each) do
        @attr = { :name =>"", :email =>"", :password =>"",
				   :password_confirmation => ""}
      end
      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end
      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector('title', :content => "Edit user")
      end

    end  
    describe "success" do 
      before(:each) do
        @attr = { :name =>"New Name", :email =>"user@example.org", 
		  :password => "barbaz",   :password_confirmation => "barbaz"}

      end  
      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        user = assigns(:user)
        @user.reload
        @user.name.should == user.name
        @user.email.should == user.email
        @user.encrypted_password.should == user.encrypted_password
      end
      it "should have the success flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/i
      end
    end
  end

  describe "authentication of edit/update actions" do

    before(:each) do
      @user = Factory(:user)
    end

		describe "for non-signed in users" do # success

		  it "should deny access to 'edit'" do
		    get :edit, :id => @user
		    response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
		  end

		  it "should deny access to 'update'" do
		    put :update, :id => @user, :user => {}
		    response.should redirect_to(signin_path)
		  end
		end

		describe "for signed in users" do
			before(:each) do
				wrong_user = Factory(:user, :email => "user@example.net")
				test_sign_in(wrong_user)
			end

		  it "should require matching users for 'edit'" do
		    get :edit, :id => @user
		    response.should redirect_to(root_path)
 		  end

		  it "should matching users for 'update'" do
		    put :update, :id => @user, :user => {}
		    response.should redirect_to(root_path)
 		  end
		end
  end

  describe "follow pages" do
    describe "when not signed in" do
      it "should protect 'following'" do
        get :following, :id => 1
        response.should redirect_to(signin_path)
      end
      it "should protect 'followers'" do
        get :followers, :id => 1
        response.should redirect_to(signin_path)
      end
    end
    describe "when signed in" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @other_user = Factory(:user, :email => Factory.next(:email))
        @user.follow!(@other_user)
      end
      it "should show 'following'" do
        get :following, :id => @user
        response.should have_selector('a', :href => user_path(@other_user),
                                           :content => @other_user.name)
      end
      it "should show 'followers'" do
        get :followers, :id => @other_user
        response.should have_selector('a', :href => user_path(@user),
                                           :content => @user.name)
      end
    end
  end
end
