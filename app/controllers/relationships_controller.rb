class RelationshipsController < ApplicationController
  before_filter :authenticate

  def create
#    raise params.inspect
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)
    respond_to do |format|
      format.html {redirect_to @user}
      format.js
    end
    flash[:success] = "You are now following"
  end

  def destroy
#    rs = Relationship.find(params[:id]).destroy
#    redirect_to(rs.followed) 
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    respond_to do |format|
      format.html {redirect_to @user}
      format.js
    end
    flash[:success] = "You are no longer following"
   end


end
