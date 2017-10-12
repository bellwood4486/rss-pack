class SessionsController < ApplicationController
  def new
    @identity = Identity.new
  end

  def create
    @identity = Identity.new(session_create_params)
    if @identity.invalid?
      render 'new'
      return
    end

    user = User.find_by(email: @identity.email.downcase)
    if user && user.authenticate(@identity.password)
      log_in user
      redirect_back_or root_url
    else
      flash.now[:error] = 'メールアドレスまたはパスワードが正しくありません'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def session_create_params
    params.require(:identity).permit(:email, :password)
  end
end
