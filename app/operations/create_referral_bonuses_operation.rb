module CreateReferralBonusesOperation
  class << self

    def call(user_id, amount, pay_in_id, error_tracker: OperationUtils::ErrorTracker.new)
      begin
        result = process(user_id, amount, pay_in_id)
      rescue OperationUtils::Exceptions::Payment::CreateReferralBonusesOperationError => e
        error_tracker.add_errors(e.errors)
      end

      OperationUtils::OperationResponseBuilder.call(result, error_tracker)
    end

    private

      def process(user_id, amount, pay_in_id)
        pay_in = PayIn.find(pay_in_id)
        referral_bonus_record = create_referral_bonus_record(pay_in_id, pay_in.currency)

        user = get_user(user_id)
        ancestors = user.ancestors.to_a # convert into array, so can run shift command
        create_payment_record_for_direct_parent(amount, pay_in.currency, referral_bonus_record.id, ancestors.shift)

        return referral_bonus_record if ancestors.none? || !ancestors.first.leader?

        create_payment_record_for_lvl1_parent(amount, pay_in.currency, referral_bonus_record.id, ancestors.shift)
        create_payment_record_for_lvl2_parent(amount, pay_in.currency, referral_bonus_record.id, ancestors.shift)
        create_payment_record_for_lvl3_parent(amount, pay_in.currency, referral_bonus_record.id, ancestors.shift)
        create_payment_record_for_lvl4_parent(amount, pay_in.currency, referral_bonus_record.id, ancestors.shift)
        create_payment_record_for_lvl5_parent(amount, pay_in.currency, referral_bonus_record.id, ancestors.shift)

        ancestors.each do |ancestor|
          create_payment_record_for(ancestor, amount, pay_in.currency, referral_bonus_record.id)
        end
      end

      def create_referral_bonus_record(pay_in_id, currency)
        ReferralBonus.create!(pay_in_id: pay_in_id, currency: currency)
      end

      def create_payment_record_for_direct_parent(amount, currency, referral_bonus_record_id, receiver_user)
        amount = get_min_amount(amount, currency, receiver_user)
        direct_referal_amount = ::Utilities::Calculator.calculate_interest(amount, 5)

        create_payment(receiver_user, direct_referal_amount, currency, referral_bonus_record_id)
      end

      def create_payment_record_for_lvl1_parent(amount, currency, referral_bonus_record_id, receiver_user)
        amount = get_min_amount(amount, currency, receiver_user)
        bonus_amount = ::Utilities::Calculator.calculate_interest(amount, 1)

        create_payment(receiver_user, bonus_amount, currency, referral_bonus_record_id)
      end

      def create_payment_record_for_lvl2_parent(amount, currency, referral_bonus_record_id, receiver_user)
        amount = get_min_amount(amount, currency, receiver_user)
        bonus_amount = ::Utilities::Calculator.calculate_interest(amount, 0.80)

        create_payment(receiver_user, bonus_amount, currency, referral_bonus_record_id)
      end

      def create_payment_record_for_lvl3_parent(amount, currency, referral_bonus_record_id, receiver_user)
        amount = get_min_amount(amount, currency, receiver_user)
        bonus_amount = ::Utilities::Calculator.calculate_interest(amount, 0.75)

        create_payment(receiver_user, bonus_amount, currency, referral_bonus_record_id)
      end

      def create_payment_record_for_lvl4_parent(amount, currency, referral_bonus_record_id, receiver_user)
        amount = get_min_amount(amount, currency, receiver_user)
        bonus_amount = ::Utilities::Calculator.calculate_interest(amount, 0.50)

        create_payment(receiver_user, bonus_amount, currency, referral_bonus_record_id)
      end

      def create_payment_record_for_lvl5_parent(amount, currency, referral_bonus_record_id, receiver_user)
        amount = get_min_amount(amount, currency, receiver_user)
        bonus_amount = ::Utilities::Calculator.calculate_interest(amount, 0.40)

        create_payment(receiver_user, bonus_amount, currency, referral_bonus_record_id)
      end

      def create_payment_record_for(receiver_user, amount, currency, referral_bonus_record_id)
        amount = get_min_amount(amount, currency, receiver_user)
        bonus_amount = ::Utilities::Calculator.calculate_interest(amount, 0.25)

        create_payment(receiver_user, bonus_amount, currency, referral_bonus_record_id)
      end

      def create_payment(receiver_user, amount, currency, referral_bonus_record_id)
        Payment.new(
          user_id: receiver_user.id,
          receiver_wallet_number: receiver_user.wallet_number,
          wallet_holder_name: receiver_user.name,
          amount: amount,
          currency: currency,
          activity_id: referral_bonus_record_id,
          payment_type: Payment.payment_types[:referral_bonus]).pending!
      end

      def get_min_amount(amount, currency, receiver_user)
        receiver_user_maximum_paid_in_amount = receiver_user.maximum_paid_in_amount(currency)
        return amount if receiver_user_maximum_paid_in_amount.zero?
        return amount if amount < receiver_user_maximum_paid_in_amount
        receiver_user_maximum_paid_in_amount
      end

      def get_user(user_id)
        User.find(user_id)
      end

    # end of private
  end
end
