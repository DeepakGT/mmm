module CompletePaymentOperation
  class << self

    def call(payment, transaction_id, error_tracker: OperationUtils::ErrorTracker.new)
      begin
        result = process(payment, transaction_id)
      rescue OperationUtils::Exceptions::Payment::CompletePaymentOperationError => e
        error_tracker.add_errors(e.errors)
      end

      OperationUtils::OperationResponseBuilder.call(result, error_tracker)
    end

    private

      def process(payment, transaction_id)
        ActiveRecord::Base.transaction do
          payment.transaction_id = transaction_id
          payment.complete!

          if payment.pay_in?
            payment.pay_in.locked!
            payment.pay_in.referral_bonus.active!
          end
        end
      rescue
        add_errors('Payment could not be complete.')
      end

      def add_errors(error)
        LogNotifierService.call(error)
        raise OperationUtils::Exceptions::Payment::CompletePaymentOperationError.new(error)
      end

    # end of private

  end
end
