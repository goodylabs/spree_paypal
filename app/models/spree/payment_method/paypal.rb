# encoding: UTF-8

module Spree
  class PaymentMethod::Paypal < Spree::PaymentMethod
    preference :private_key, :string
    preference :public_key, :string

    attr_accessible :preferred_private_key, :preferred_public_key

    def payment_source_class
      CreditCard
    end

    def authorize(money, credit_card, options = {})
      init_data
      order = find_order(options)

      client = ::Paypal::Client.create(
        email: "#{options[:email]}"
      )

      unless client.id.nil?
        payment = create_payment(order, client, credit_card, options)

        unless payment.id.nil?
          preauth = create_preauthorization(payment, money)

          unless preauth.id.nil?
            ActiveMerchant::Billing::Response.new(true, 'Paypal creating preauthorization successful', {}, :authorization => preauth.preauthorization["id"])
          else
            ActiveMerchant::Billing::Response.new(false, 'Paypal creating preauthorization unsuccessful')
          end
        else
          ActiveMerchant::Billing::Response.new(false, 'Paypal creating payment unsuccessful')
        end
      else
        ActiveMerchant::Billing::Response.new(false, 'Paypal creating client unsuccessful')
      end
    end

    def capture(authorization, credit_card, options = {})
      init_data
      order = find_order(options)
      transaction = create_transaction(authorization, order)

      unless transaction.id.nil?
        ActiveMerchant::Billing::Response.new(true, 'Paypal creating transaction successful', {}, :authorization => transaction.id)
      else
        ActiveMerchant::Billing::Response.new(false, 'Paypal creating transaction unsuccessful')
      end
    end

  private
    def init_data
      ::Paypal.api_key = preferred_private_key
    end

    def find_order(options = {})
      Spree::Order.find_by_number(options[:order_id])
    end

    def create_transaction(authorization, order)
      ::Paypal::Transaction.create(
        amount: authorization,
        preauthorization: order.payment.response_code,
        currency: "EUR"
      )
    end

    def create_payment(order, client, credit_card, options = {})
      ::Paypal::Payment.create(
        id: "pay_#{options[:order_id]}",
        client: "#{client.id}",
        card_type: credit_card.spree_cc_type,
        token: order.payment.response_code,
        country: nil,
        expire_month: credit_card.month,
        expire_year: credit_card.year,
        card_holder: nil,
        last4: credit_card.display_number[15..18],
        created_at: Time.zone.now,
        updated_at: Time.zone.now
      )
    end

    def create_preauthorization(payment, money)
      ::Paypal::Preauthorization.create(
        payment: payment.id,
        amount: money,
        currency: "EUR"
      )
    end
  end
end
