module SubscriptionHelper
  def formatted_subscription_message(subscription)
    if subscription.message.present?
      "#{subscription.message}(#{subscription.messaged_at}現在)"
    else
      nil
    end
  end
end
