module Spree
  class Gateway::PayPal < Gateway
    preference :login, :string
    preference :password, :string
    preference :signature, :string
    preference :currency_code, :string
    
    attr_accessible :preferred_login, :preferred_password, :preferred_signature, :preferred_currency_code

    def provider_class
      ActiveMerchant::Billing::PaypalGateway
    end

    def auto_capture?
      true
    end

    def purchase(money, credit_card_or_referenced_id, options = {})

      puts "****************"
      puts credit_card_or_referenced_id.inspect

      payment = Spree::Payment.find_by_source_id(credit_card_or_referenced_id)
      errors.add(:payment, "couldn't find corresponding payment") if payment.nil?

      puts "****************"
      puts payment.response_code.inspect


      if payment.response_code.present?
        #set token to null

        response = provider.capture(money,payment.response_code, options)
      end

      response
    end

    def void(response_code, credit_card, options = {})
      amount = credit_card[:subtotal].to_i + credit_card[:tax].to_i + credit_card[:shipping].to_i
      options[:currency] = credit_card[:currency]
      Rails.logger.warn "====> PayPal void: amount: #{amount}, response_code: #{response_code}, options: #{options}"
      provider.refund(amount, response_code, options)
    end

  end
end
