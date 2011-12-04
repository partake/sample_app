class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end
  def create
    user = User.authenticate(params[:session][:email],
			     params[:session][:password])
    if user.nil?
     flash.now[:error] = "Invalid email/password combination"
     @title = "Sign in"
     render 'new'
    else
     sign_in user
     flash[:success] = "Welcome to Sample App, #{user.name}!"
     redirect_back_or user
    end
  end
  def destroy
# Both work
#    flash[:success] = "You have signed out sucessfully, #{current_user.name}!"
    flash[:success] = "You have signed out sucessfully."
    sign_out
    redirect_to root_path
  end

end

