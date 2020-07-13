class Api::Owner::V1::SubscriptionsController < Api::Owner::V1::ApiController

  before_action :get_user, only: [:create, :cancel_subscription, :check_subscription]

  def create
    token = params[:subscription][:stripeToken]
    begin
      # Create a Customer:
      customer = Stripe::Customer.create(
        :email => current_user.email,
        :source => token
      )
      stripe_plan = "plan_GzFw0XV0tcckKY"
      subscription = Stripe::Subscription.create(
        customer: customer,
        items: [
          {
              plan: stripe_plan,
          }
        ]
      )

      @user.update(stripe_id: customer[:id])

      @user.save
      render json: {success: true}
    rescue Exception => e
      render json: { error: true, message: e.message }
    end
  end

  def cancel_subscription
    begin
      # Fetch credit card and subscription information about the customer
      customer = @user.get_stripe_customer
      if customer.subscriptions.total_count > 0
        # Cancel the subscription, but keep it active until expiration date
        Stripe::Subscription.delete(customer.subscriptions.data[0].id)

        render json: {success: true, message: "Subscription cancelled"}
      else
        # Customer does not have a subscription, how did they get here?!?
        render json: {error: true, message: "No subscriptions found"}
      end
    rescue Exception => e
      render json: {error: true, message: e.message}
    end
  end

  def check_subscription
    begin
      subscription_details = {}
      if @user.stripe_id.present?
        customer = @user.get_stripe_customer
        @stripe_client = StripeService.new(customer)
        total_subs = @stripe_client.total_subscription
        if total_subs > 0
          status = @stripe_client.subscription_status
          if status == 1
            subscription_details = {
              "stripe_id": @user.stripe_id,
              "is_owner_subscribed": status,
              "renewable_date": Time.at(@stripe_client.stripe_invoice.next_payment_attempt),
              "period_start": Time.at(@stripe_client.stripe_invoice.period_start),
              "period_end": Time.at(@stripe_client.stripe_invoice.period_end),
              "current_payment_method": @stripe_client.latest_payment_method,
              "previous_payments": @stripe_client.payment_methods,
              "payment_methods": @stripe_client.payment_methods
            }
            render json: {success: true, details: subscription_details, message: "Your subscription is active."}
          else
            render json: {success: false, is_owner_subscribed: status, message: "Your subscriptions is cancelled."}
          end
        else
          render json: {success: false, is_owner_subscribed: 2, message: "You dont have any subscription."}
        end
      else
        render json: {success: false, is_owner_subscribed: 0, message: "You dont have any subscription."}
      end
    rescue Exception => e
      render json: {success: false, message: e.message}
    end
  end

  private

  def get_user
    @user = current_user
  end

end
