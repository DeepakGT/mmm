module CreatePayOutPaymentOperation
  class << self
    def call(user_id, error_tracker: OperationUtils::ErrorTracker.new)
      begin
        result = process(user_id)
      rescue OperationUtils::Exceptions::Payment::CreatePayOutPaymentOperationError => e
        error_tracker.add_errors(e.errors)
      end

      OperationUtils::OperationResponseBuilder.call(result, error_tracker)
    end

    private
      def process(user_id)
        user = get_user(user_id)
        unlocked_pay_in = user.first_unlocked_pay_in_with_no_pay_out

        ActiveRecord::Base.transaction do
          releasable_amount, not_releasable_amount = 
            releasable_and_not_releasable_amount(user, unlocked_pay_in)

          pay_out = create_pay_out(user, unlocked_pay_in.id, unlocked_pay_in.currency)
          create_payment(user, pay_out, releasable_amount, unlocked_pay_in.currency)
          update_user_wallet(user, not_releasable_amount, unlocked_pay_in.currency)
        end

      rescue ActiveRecord::RecordInvalid
        add_errors('payOut payment could not be created.')
      end

      def releasable_and_not_releasable_amount(user, unlocked_pay_in)
        principal_amount = unlocked_pay_in.amount
        currency = unlocked_pay_in.currency
        growth_amount = unlocked_pay_in.total_growth
        welcome_bonus = user.get_welcome_bonus(principal_amount)
        referral_bonus_amount = user.total_referral_bonus_amount
        wallet_balance = user.wallet_balance(currency)
        total_amount = ::Utilities::Calculator.total_payout_amount(principal_amount, growth_amount, wallet_balance, welcome_bonus, referral_bonus_amount)
        not_releasable_amount = total_amount%10
        releasable_amount = total_amount - not_releasable_amount
        [releasable_amount, not_releasable_amount]
      end

      def create_pay_out(user, unlocked_pay_in_id, currency)
        pay_out = user.pay_outs.new(pay_in_id: unlocked_pay_in_id, currency: currency)
        pay_out.open!
        pay_out
      end

      def create_payment(user, pay_out, releasable_amount, currency)
        Payment.new(amount: releasable_amount,
                    currency: Payment.currencies[currency],
                    receiver_wallet_number: user.wallet_number,
                    wallet_holder_name: user.name,
                    user_id: user.id,
                    activity_id: pay_out.id,
                    payment_type: Payment.payment_types[:pay_out]).pending!
      end

      def update_user_wallet(user, not_releasable_amount, currency)
        user.wallets.send(currency.downcase).first.update!(amount: not_releasable_amount.to_f.round(2))
      end

      def get_user(user_id)
        User.find(user_id)
      end

      def add_errors(error)
        LogNotifierService.call(error)
        raise OperationUtils::Exceptions::Payment::CreatepayOutPaymentOperationError.new(error)
      end
    # end of private
  end
end
