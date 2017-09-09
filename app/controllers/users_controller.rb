class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_create_params)
    if @user.save
      log_in @user
      redirect_to root_url, notice: 'ユーザー登録が完了しました！'
    else
      render :new
    end
  end

  def destroy
    current_user.destroy
    redirect_to users_url
  end

  private

  def user_create_params
    params.require(:user).permit(:email,
                                 :password, :password_confirmation)
  end
end
