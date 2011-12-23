class PagesController < ApplicationController
  
  def home
   @title = "Home"
   if signed_in?
     @feed_items = current_user.feed.paginate(:page => params[:page])
     @micropost = Micropost.new 
   end
  end

  def contact
   @title = "Contact"
  end

  def about
   @title = "About"
  end

  def help
   @title = "Help"
  end

 def signup
   @title = "Sign Up"
  end

end
