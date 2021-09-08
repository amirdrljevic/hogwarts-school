class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    #debugger
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      reset_session
      log_in @user
      flash[:success] = "Dear #{ @user.name }, welcome to Hogwarts School of Witchcraft and Wizardry!"
      redirect_to @user
    else 
      render 'new'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :date_of_birth, :bio, :has_muggle_relatives, :password,
                                   :password_confirmation)
    end  
end
