Spree::Order.class_eval do

  Spree::Order.state_machine.before_transition :to => :confirm, :do => :process_if_paypal

  # Used by the checkout state machine to check for unprocessed payments
  # The Order should be unable to proceed to complete if there are unprocessed
  # payments and there is payment required.
  def has_unprocessed_payments?
    payments.select{|p| p.state == 'checkout' or (p.payment_method.kind_of?(Spree::Gateway::PayPal) and p.state == 'pending')}.size > 0
    #with_state('checkout').reload.exists?
  end

  def pending_payments
    payments.select{|p| p.state == 'checkout' or (p.payment_method.kind_of?(Spree::Gateway::PayPal) and p.state == 'pending')}
  end

  protected

  def process_if_paypal
    self.pending_payments.each do |payment|
      unless payment.completed?
        if payment.payment_method.kind_of?(Spree::Gateway::PayPal)
          response = payment.authorize!
        end
      end
    end

  end

end