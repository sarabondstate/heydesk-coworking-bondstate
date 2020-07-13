
Stripe.api_key = 'sk_test_s41VojF2cAB2jzLnQW8RPt0u'
Rails.configuration.stripe_public_key = 'pk_test_4RMfOSp2JV4t3IFU7EyxrRny'

if ENV['STRIPE_KEY'].present?
  Stripe.api_key = ENV['STRIPE_KEY']
end

if ENV['STRIPE_PUBLIC_KEY'].present?
  Rails.configuration.stripe_public_key = ENV['STRIPE_PUBLIC_KEY']
end