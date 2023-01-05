module CreatePayInPaymentsOperation
  class << self

    ASSURANCE_AMOUNT_PERCENT = 2
    
    def call(user_id, pay_in_id, amount, currency, error_tracker: OperationUtils::ErrorTracker.new)
      begin
        result = process(user_id, pay_in_id, amount, currency)
      rescue OperationUtils::Exceptions::CreatePayInPaymentsOperationError => e
        error_tracker.add_errors(e.errors)
      end

      OperationUtils::OperationResponseBuilder.call(result, error_tracker)
    end

    private
      
      def process(user_id, pay_in_id, amount, currency)
        create_assurance_payment(user_id, amount, pay_in_id, currency)
        create_pay_in_payment(user_id, amount, pay_in_id, currency)
      rescue
        add_errors('Payments could not be create.')
      end

      def create_assurance_payment(user_id, amount, pay_in_id, currency)
        Payment.new(
          user_id: user_id,
          receiver_wallet_number: Payment::ASSURANCE_AMOUNT_WALLET_NUMBER,
          wallet_holder_name: Faker::Name.name,
          amount: assurance_amount(amount),
          currency: Payment.currencies[currency],
          activity_id: pay_in_id,
          payment_type: Payment.payment_types[:assurance]).pending!
      end

      def create_pay_in_payment(user_id, amount, pay_in_id, currency)
        Payment.new(
          user_id: user_id,
          receiver_wallet_number: Payment::WALLET_NUMBERS.sample,
          wallet_holder_name: Faker::Name.name,
          amount: amount,
          currency: Payment.currencies[currency],
          activity_id: pay_in_id,
          payment_type: Payment.payment_types[:pay_in]).pending!
      end

      def assurance_amount(amount)
        # do not remove to_f
        amount.to_f * ASSURANCE_AMOUNT_PERCENT/100
      end

      def add_errors(error)
        LogNotifierService.call(error)
        raise OperationUtils::Exceptions::CreatePayInPaymentsOperationError.new(error)
      end


    # end of private
  end
end
