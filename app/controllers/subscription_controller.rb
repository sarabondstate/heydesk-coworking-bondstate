class SubscriptionController < ApplicationController
  load_and_authorize_resource except: [:index, :change_subscription,:cancel_subscription, :reactivate_subscription, :make_new_subscription, :change_credit_card]

  def index

    if current_user.is_trainer_in_stable?(current_stable)

      @stripe_customer = nil
      # If user has a Stripe id, then look up the card info and subscription info
      unless current_user.stripe_id.nil?
        begin
          # Fetch credit card and subscription information about the customer
          @stripe_customer = current_user.get_stripe_customer
        rescue Exception => ex
          Rails.logger.info ex
          p ex
          # Could not fetch the Stripe information
        end
      end

      @plan_id = current_stable.plan_id

    else
      redirect_to :controller => 'users', :action => 'index'
    end

  end

  def change_subscription
    stripe_plan_id = Plan.find(params[:plan_id]).details
	  begin
      # Fetch credit card and subscription information about the customer
      if current_user.stripe_id
        customer = current_user.get_stripe_customer
        if customer.subscriptions.total_count > 0
          # select another subscription plan
          subscription = customer.subscriptions.retrieve(customer.subscriptions.data[0].id)
          subscription.plan = stripe_plan_id
          subscription.save
          flash[:info] = translate('profile.subscription_changed')
        else
          # Customer does not have a subscription, how did they get here?!?
          raise 'No subscriptions found'
        end
      else
      end
      current_stable.update_attributes(plan_id: params[:plan_id])
    rescue Exception => e
      p e
      flash[:danger] = translate('profile.subscription_not_canceled_error')
    end

    redirect_to :action => 'index'
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
      	if current_stable.plan_id
      		stripe_plan_id = Plan.find(current_stable.plan_id).details
	        # Make request to stripe to reactive the subscription
	        Stripe::Subscription.create(
	            customer: customer,
	            items: [
	                {
	                   plan: stripe_plan_id,#'stable-app',
	               }
	           ]
	        )
	        flash[:info] = translate('profile.subscription_activated')
	    else
	    	flash[:info] = translate('subscription.select_a_subscription')
	    end
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

  def change_credit_card
  	begin
      token = params[:stripeToken]
      if current_user.stripe_id.nil?
      	if current_stable.plan_id
      	  stripe_plan_id = Plan.find(current_stable.plan_id).details
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
                    plan: stripe_plan_id,#'stable-app',
                }
            ]
          )
          current_user.stripe_id = customer[:id]
          current_user.save
        else
	        flash[:info] = translate('subscription.select_a_subscription')
	        raise 'Does not have a subscription'
	      end
      else
        # If customer has Stripe id, just add the card and set it as default source
        customer = current_user.get_stripe_customer
        # Save the card
        card = customer.sources.create(card: token)
        card.save
        # Set it as default card on customer
        customer.default_source = card.id
        customer.save
        flash[:info] = translate('profile.credit_card_changed')
      end
    rescue Exception => e
      p e
      flash[:danger] = translate('profile.credit_card_not_changed_error')
    end
    redirect_to :action => 'index'
  end

end
