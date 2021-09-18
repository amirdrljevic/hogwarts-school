class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :following, :followers]  
  before_action :correct_user,   only: [:edit, :update]  
  before_action :admin_user,     only:  :destroy

  def show
    @user = User.find(params[:id])
    @spells = @user.spells.paginate(page: params[:page])
    #debugger
  end

  def new
    @user = User.new
  end

  def create
    if current_user&.admin? 
      @user = User.new(user_params_upd_for_admins)
      @user.skip_this_for_dumbledore = true
      if @user.save
        @user.activate        
        flash[:info] = "New profile for has been created."
        redirect_to @user
      else 
        render 'new'
      end        
    else
      @user = User.new(user_params_upd_for_admins)
      if @user.save 
        @user.send_activation_email
        flash[:info] = "Please check your email to activate your account."
        redirect_to root_url
      else 
        render 'new'
      end    
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if current_user.admin?
      if @user.update(user_params_upd_for_admins)
        flash[:success] = "Profile updated"
        redirect_to @user
      else
        render 'edit'
      end
    else      
      if @user.update(user_params_upd)
        flash[:success] = "Profile updated"
        redirect_to @user
      else
        render 'edit'
      end
    end
  end

  def index
    @users = User.order('id asc').paginate(page: params[:page])
  end  

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

    # Confirm an admin user    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

    #Strong parameters for creating new users
    def user_params
      params.require(:user).permit(:name, :email, :date_of_birth, :bio, :has_muggle_relatives, :password,
                                   :password_confirmation)
    end  

    # Strong parameters for updating users
    def user_params_upd
      params.require(:user).permit(:name, :date_of_birth, :bio, :has_muggle_relatives, :password,
                                   :password_confirmation)
    end     

    #Strong parameters for updating, for admins only
    def user_params_upd_for_admins
      params.require(:user).permit(:name, :email, :date_of_birth, :bio, :has_muggle_relatives, :house, :password,
                                   :password_confirmation)
    end  

    # Before filters

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user) || current_user.admin?
    end    
end
