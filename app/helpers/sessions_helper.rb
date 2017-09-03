module SessionsHelper

  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    User.first
    # TODO 実装
#     if (user_id = session[:user_id])
#       @current_user ||= User.find_by(id: user_id)
#     elsif (user_id = cookies.signed[:user_id])
#       user = User.find_by(id: user_id)
#       if user && user.authenticated?(:remember, cookies[:remember_token])
#         log_in user
#         @current_user = user
#       end
#     end
  end
end
