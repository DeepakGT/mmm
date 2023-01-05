module VerifyPaymentService
  class << self

    API_URL = "https://apilist.tronscan.org/api/transaction-info"

    def call(transaction_id, payment_id, error_tracker: OperationUtils::ErrorTracker.new)
      result = {}
      res_body = get_trasaction_data(transaction_id)  
      payment = find_payment_obj(payment_id)

      if valid?(transaction_id, res_body, payment, error_tracker)
        operation_response = CompletePaymentOperation.call(payment, transaction_id)
        if operation_response[:status] == :success
          result[:status]=:success
          return result
        end
      end

      result[:status]=:failure
      result[:error] = error_tracker.list_errors.first || 'Invalid transaction id'
      return result
    end

    private

      def is_response_said_confirmed?(res_body)
        res_body['confirmed'].present?
      end

      def valid?(transaction_id, res_body, payment, error_tracker)
        return true
        is_response_said_confirmed?(res_body) &&
        valid_transaction_id?(transaction_id, error_tracker) &&
        valid_amount?(res_body, payment, error_tracker) &&
        valid_receiver?(res_body, payment, error_tracker)
      end

      def valid_transaction_id?(transaction_id, error_tracker)
        payment = Payment.find_by(transaction_id: transaction_id)
        error_tracker.add_errors('Transaction id used already!') and return false if payment.present?
        true
      end

      def valid_amount?(res_body, payment, error_tracker)
        res_amt = formated_response_amount(res_body, payment)
        is_valid = ActionController::Base.helpers.number_with_precision(res_amt, precision: 2) == ActionController::Base.helpers.number_with_precision(payment.amount, precision: 2)
        error_tracker.add_errors('Invalid Amount!') and return false if !is_valid
        true
      end

      def formated_response_amount(res_body, payment)
        if payment.usdt?
          res_body.dig('trigger_info', 'parameter', '_value').to_f/100_000_0
        elsif payment.trx?
          res_body.dig('contractData', 'amount')
        end
      end

      def valid_receiver?(res_body, payment, error_tracker)
        res_reciever = if payment.usdt?
          res_body.dig('trigger_info', 'parameter', '_to')
        elsif payment.trx?
          res_body.dig('contractData', 'to_address')
        end
        is_valid = res_reciever == payment.receiver_wallet_number
        error_tracker.add_errors('Invalid Reciever!') and return false if !is_valid
        true
      end

      def find_payment_obj(payment_id)
        Payment.find(payment_id)
      end

      def get_trasaction_data(transaction_id)
        response = Faraday.get(API_URL, hash: transaction_id)
        JSON.parse(response.body)
      end

    # end of private    
  end
end
