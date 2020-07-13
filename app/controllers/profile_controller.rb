class ProfileController < ApplicationController
  load_and_authorize_resource except: [:index, :update, :download_pdf, :cancel_subscription, :reactivate_subscription, :make_new_subscription, :change_credit_card]
  skip_before_action :check_terms_accepted_and_logged_in, only: [:download_pdf]
  def index

    @stripe_customer = nil

    # If user has a Stripe id, then look up the card info and subscription info
    unless current_user.stripe_id.nil?

      begin

        # Fetch credit card and subscription information about the customer
        @stripe_customer = current_user.get_stripe_customer

      rescue Exception => ex
        p ex
        # Could not fetch the Stripe information
      end

    end

  end

  def update
    begin

      # Check if customer has Stripe id, and if so update the email in Stripe
      if !current_user.stripe_id.nil? && current_user.email != user_params[:email]
        customer = current_user.get_stripe_customer
        customer.email = user_params[:email]
        customer.save
      end

      # Update user information
      if current_user.update_attributes!(user_params)
        if current_user.is_a_trainer?
          current_stable.update_attributes!(stable_params)
        end
      end
      flash[:info] = translate('profile.update_success')

    rescue => ex
      p ex
      flash[:danger] = translate('profile.update_failed')
    end
    redirect_to :action => 'index'
  end

  def download_pdf
    send_file "#{Rails.root}/app/assets/uploads/Privacy Policy Mosson.pdf", type: "application/pdf", x_sendfile: true
  end

  def cancel_subscription

    begin

      # Fetch credit card and subscription information about the customer
      customer = current_user.get_stripe_customer

      if customer.subscriptions.total_count > 0

        # Cancel the subscription, but keep it active until expiration date
        sub = Stripe::Subscription.retrieve(customer.subscriptions.data[0].id)
        sub.delete(
            :at_period_end => true
        )

        flash[:info] = translate('profile.subscription_canceled')

      else
        # Customer does not have a subscription, how did they get here?!?
        raise 'No subscriptions found'
      end

    rescue Exception => e
      p e
      flash[:danger] = translate('profile.subscription_not_canceled_error')
    end

    redirect_to :action => 'index'

  end

  def reactivate_subscription

    begin

      customer = current_user.get_stripe_customer

      if customer.subscriptions.total_count > 0

        # Make request to stripe to reactive the subscription
        sub = Stripe::Subscription.retrieve(customer.subscriptions.data[0].id)
        sub.cancel_at_period_end = false
        sub.save

        flash[:info] = translate('profile.subscription_reactivated')
      else
        # Customer already has an subscription, how did they get here?!?
        raise 'Already has a subscription'
      end

    rescue Exception => e
      p e
      flash[:danger] = translate('profile.subscription_not_reactivated_error')
    end

    redirect_to :action => 'index'

  end

  def make_new_subscription

    begin

      customer = current_user.get_stripe_customer

      if customer.subscriptions.total_count == 0

        # Make request to stripe to reactive the subscription
        Stripe::Subscription.create(
            customer: customer,
            items: [
                {
                   plan: 'stable-app',
               }
           ]
        )

        flash[:info] = translate('profile.subscription_activated')

      else
        # Customer already has an subscription, how did they get here?!?
        raise 'Already has a subscription'
      end

    rescue Exception => e
      p e
      flash[:danger] = translate('profile.subscription_not_activated_error')
    end

    redirect_to :action => 'index'

  end

  # This method also creates a stripe customer and subscription if none exists
  def change_credit_card

    begin

      token = params[:stripeToken]

      if current_user.stripe_id.nil?

        # If customer does not have a Stripe id, create it. This is a "hack" for manually created customers.
        # All new customers will have a Stripe id
        customer = Stripe::Customer.create(
            :email => current_user.email,
            :source => token
        )

        Stripe::Subscription.create(
            customer: customer,
            items: [
                {
                    plan: 'stable-app',
                }
            ]
        )

        current_user.stripe_id = customer[:id]
        current_user.save

      else

        # If customer has Stripe id, just add the card and set it as default source
        customer = current_user.get_stripe_customer

        # Save the card
        card = customer.sources.create(card: token)
        card.save

        # Set it as default card on customer
        customer.default_source = card.id
        customer.save

      end

      flash[:info] = translate('profile.credit_card_changed')

    rescue Exception => e
      p e
      flash[:danger] = translate('profile.credit_card_not_changed_error')
    end

    redirect_to :action => 'index'

  end

  private
  def user_params
    if current_user.is_a_trainer?
      params.require(:user).permit(:firstname, :lastname, :email, :phone, :address, :zip, :city)
    else
      params.require(:user).permit(:firstname, :lastname, :email, :phone)
    end
  end

  def stable_params
    params.require(:user).require(:stable).permit(:name, :cvr)
  end

end
