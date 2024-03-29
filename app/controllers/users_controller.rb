class UsersController < ApplicationController				  
#	before_filter :authenticate, :only => [:index, :edit, :update]
	before_filter :authenticate, :except => [:show, :new, :create]
	before_filter :correct_user, :only => [:edit, :update]

  def show
    @user = User.find(params[:id])
    @title = @user.name
    @microposts = @user.microposts.paginate(:page => params[:page])
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
#    raise params.inspect
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
  end

  def new
   @user = User.new
   @title = "Sign up"
  end 
		
	def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
	end

	def destroy
#		  User.find(params[:id]).destroy
			@user.destroy
		  flash[:success] = "User destroyed."
		  redirect_to users_path
	end


  def create
#    raise params[:user].inspect
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App, #{@user.name}!"
      redirect_to user_path(@user)
    else
      @title = "Sign up"
      render 'new'
    end
  end

  def edit
#		raise request.inspect
    @user = User.find(params[:id])
    @title = "Edit user"
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated successfully!"
      redirect_to @user
    else
    @title = "Edit user"
    render 'edit'
    end
  end

  private 

    def admin_user
      @user = User.find(params[:id])
      redirect_to(root_path) if !current_user.admin? || current_user?(@user)
    end

    def correct_user
			@user = User.find(params[:id])
			redirect_to(root_path) unless current_user?(@user)
    end



end
