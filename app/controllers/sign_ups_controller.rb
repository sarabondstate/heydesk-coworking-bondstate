class SignUpsController < ApplicationController
  include Wicked::Wizard
  include ApplicationHelper

  skip_before_action :check_terms_accepted_and_logged_in
  before_action :setup_objects
  steps :select_plan, :basic_details, :payment, :receipt

  def show
    if step == :receipt
      session[:user_params] = nil
      render_wizard @user
      return
    end
    # Redirect to start of signup flow if plan_id is not set
    if step != :select_plan && !session[:plan_id]
      jump_to(:select_plan)
    end
    render_wizard
  end

  def update
    case step
      when :select_plan
        session[:plan_id] = params[:submit]
        puts  session[:plan_id]
        jump_to :basic_details
      when :basic_details
        session[:selected_stable_type] = params[:selected_stable_type]
        session[:user_params] = user_params
        session[:country] = session[:user_params]['country']
        @user.assign_attributes(user_params)
        session[:generated_password] = random_string(8)
        @user.assign_attributes(password: session[:generated_password], password_confirmation: session[:generated_password])
        @user.assign_attributes(name: user_params[:firstname] + " " + user_params[:lastname])
        unless @user.validate(:trainer)
          jump_to :basic_details
          @object = @user
        else
          jump_to :payment
        end
      when :payment
        token = params[:stripeToken]
        coupon = params[:user][:coupon]
        check_valid_coupon = params[:user][:check_applied]
        begin
          # Create a Customer:
          customer = Stripe::Customer.create(
            :email => @user.email,
            :source => token
          )
          stripe_plan_id = Plan.find(session[:plan_id]).details
          puts stripe_plan_id
          if check_valid_coupon.present? && coupon.present? && (check_valid_coupon == "true")
            Stripe::Subscription.create(
              customer: customer,
              items: [
                {
                    plan: stripe_plan_id,
                }
              ],
              coupon: coupon,
            )
          else
            Stripe::Subscription.create(
              customer: customer,
              items: [
                {
                    plan: stripe_plan_id,
                }
              ]
            )
          end

          @user.stripe_id = customer[:id]
          stable = @user.stable
          @user.stable = nil
          # Because @user is a trainer, create a true user object from the same attributes
          user = User.new
          user.assign_attributes(@user.attributes.except('stable_id', 'agreement_accept'))
          user.assign_attributes(password: session[:generated_password], password_confirmation: session[:generated_password])
          user.assign_attributes(name: @user.firstname + " " + @user.lastname)
          # This creates the user and logs him in instantly
          user.save

          stable.assign_attributes(
              stable_type_id: session[:selected_stable_type],
              address: '',
              telephone: '',
              zip: '',
              city: '',
              active: true,
              plan_id: session[:plan_id],
              trainer_id: user.id
          )
          stable.save

          user.user_stable_roles << UserStableRole.new(stable: stable, role: 'trainer')

          UserMailer.trainer_is_created(user, session[:generated_password]).deliver_now

          jump_to :receipt
          @object = nil
        rescue Exception => e
          p e
          flash[:danger] = e.message
          jump_to :payment
        end
    end
    render_wizard @object
  end

  def check_coupon
    begin
      if params[:coupon].present?
        coupon = Stripe::Coupon.retrieve(params[:coupon])
        if coupon.present? && coupon.valid
          valid_or_exists = coupon.valid
        else
          valid_or_exists = false
        end
        respond_to do |format|
          format.json  { render :json => valid_or_exists }
        end
      else
        respond_to do |format|
          format.json  { render :json => false }
        end
      end
    rescue Exception => e
      render :json => "No Coupon found"
    end
  end

  private
  def setup_objects
    if session[:country].nil?
      session[:country] = locale_to_country(I18n.locale)
    end
    session[:product_country] = session[:country]
    unless ["DA", "SE", "NO"].include?(session[:country])
      session[:product_country] = ""
    end
    @user = Trainer.new(session[:user_params])
    @user.stable = Stable.new if @user.stable.nil?

    @list = StableType.all
    @list.each do |type_obj|
      type_obj.stable_type = I18n.t('sign_up.stable_type_' + type_obj.stable_type)
    end
  end

  def user_params
    params.require(:trainer).permit(:firstname, :lastname, :email, :phone, :address, :zip, :city, :country, :agreement_accept, {stable_attributes: [:name, :cvr]})
  end

  def random_string(len)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    password = ""
    1.upto(len) { |i| password << chars[rand(chars.size-1)]}
    return password
  end
end
