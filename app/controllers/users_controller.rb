class UsersController < ApplicationController

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_create_params)
    # TODO メソッドの責務は要検討
    pack = build_pack_for @user
    if @user.save
      redirect_to pack_url(pack), notice: 'ユーザー登録が完了しました！さぁフィードを追加しましょう！'
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
    params.require(:user).permit(:email)
  end

  def build_pack_for(user)
    pack = user.packs.build
    pack.token = Pack.new_token
    pack
  end
end
