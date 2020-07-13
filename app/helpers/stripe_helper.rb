module StripeHelper

  # Different types of subscription statuses that Stripe uses
  SUBSCRIPTION_TRIALING = "trialing"
  SUBSCRIPTION_ACTIVE = "active"
  SUBSCRIPTION_PAST_DUE = "past_due"
  SUBSCRIPTION_UNPAID = "unpaid"
  SUBSCRIPTION_CANCELED = "canceled"
  SUBSCRIPTION_ALL = "all"
  SUBSCRIPTION_ACTIVE_BUT_ENDING = "active_but_ending" # This does not exist in Stripe, but when the status is Active and cancel_at_period_end is true

  # 'customer' is the stripe customer. Can be fetched with 'current_user.get_stripe_customer'

  def has_default_source?(customer)

    if customer.nil?
      return false
    end

    !customer.default_source.nil?

  end

  def default_source_last4(customer)

    if has_default_source?(customer)
      customer.default_source.last4
    end

  end

  def default_source_brand(customer)

    if has_default_source?(customer)
      customer.default_source.brand
    end

  end

  def default_source_brand_asset_name(customer)

    # https://stripe.com/docs/api#card_object-brand

    asset_name = nil

    if has_default_source?(customer)
      case customer.default_source.brand
        when "MasterCard"
          asset_name = "master.png"
        when "Visa"
          asset_name = "visa.png"
      end
    end

    asset_name

  end

  def subscription_status(customer)

    status = StripeHelper::SUBSCRIPTION_CANCELED

    unless has_default_source?(customer)
      return status
    end

    if customer.subscriptions.total_count > 0

      status = customer.subscriptions.data[0].status

      # Customer has subscription
      if customer.subscriptions.data[0].status == StripeHelper::SUBSCRIPTION_ACTIVE && customer.subscriptions.data[0].cancel_at_period_end
        status = StripeHelper::SUBSCRIPTION_ACTIVE_BUT_ENDING
      end

    end

    status

  end

  def subscription_text(customer)

    status = subscription_status(customer)

    case status
      when StripeHelper::SUBSCRIPTION_ACTIVE_BUT_ENDING
        date = Time.at(customer.subscriptions.data[0].current_period_end).to_formatted_s(:long)
        status_text = t('subscription_status.active_until', {date: I18n.l(date.to_time, format: :short)})
      else
        if customer.subscriptions.total_count == 0
          status_text = translate('subscription_status.inactive')
        else
          status_text = translate('subscription_status.'+status)
        end

    end

    status_text

  end



end