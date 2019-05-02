module DeviseHelper
  def password_length_hint(minimum_password_length)
    t("devise.shared.minimum_password_length", count: @minimum_password_length) if minimum_password_length
  end
end
