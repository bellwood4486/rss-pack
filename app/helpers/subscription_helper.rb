module SubscriptionHelper
  def formatted_subscription_message(subscription)
    if subscription.message.present?
      "[#{subscription.messaged_at}現在] #{subscription.message}"
    else
      nil
    end
  end
end
