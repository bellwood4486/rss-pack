class SubscriptionsController < ApplicationController
  before_action :set_pack
  # before_action :set_feed, only: :create
  before_action :set_subscription, only: :destroy

  def index
    @subscriptions = @pack.subscriptions
  end

  def create
    @subscription = @pack.subscriptions.build(subscription_params)
    if @subscription.save
      redirect_to pack_subscriptions_url(@pack), notice: "購読を追加しました"
    else
      redirect_to new_pack_feed_url(@pack), alert: "購読を追加できませんでした"
    end
  end

  def destroy
    @subscription.destroy!
    redirect_to pack_subscriptions_url(@pack), notice: "フィードの購読を解除しました"
  end

  private

    def set_pack
      @pack = current_user.packs.find(params[:pack_id])
    end

    def subscription_params
      params.require(:subscription).permit(:feed_id)
    end

    def set_subscription
      @subscription = @pack.subscriptions.find(params[:id])
    end
end
