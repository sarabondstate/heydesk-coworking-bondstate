require 'stripe'
class StripeService
  def initialize customer
    @customer = customer
  end

  def total_subscription
    @customer.subscriptions.total_count
  end

  def subscription
    subscription = Stripe::Subscription.retrieve(@customer.subscriptions.data[0].id)
  end

  def subscription_status
    subscription = Stripe::Subscription.retrieve(@customer.subscriptions.data[0].id)
    if subscription.status == "canceled"
      return 2
    elsif subscription.status == "active"
      return 1
    end
  end

  def payment_methods
    Stripe::PaymentMethod.list({ customer: @customer.id, type: 'card' })
  end

  def stripe_invoice
    subscription = Stripe::Subscription.retrieve(@customer.subscriptions.data[0].id)
    Stripe::Invoice.upcoming({customer: @customer.id, subscription: subscription.id })
  end

  def latest_payment_method
    payment = Stripe::PaymentMethod.list({ customer: @customer.id, type: 'card' })
    payment.data.max_by{|pay| pay.created }
  end

end
