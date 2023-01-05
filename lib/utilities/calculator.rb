module Utilities
  module Calculator
    class << self
      def calculate_interest(principal_amount, interest_rate)
        principal_amount * (interest_rate.to_f / 100)
      end

      def total_payout_amount(principal_amount,
                              growth_amount,
                              wallet_balance,
                              welcome_bonus,
                              referral_bonus_amount)
        principal_amount + growth_amount + wallet_balance + welcome_bonus + referral_bonus_amount
      end
    end
  end
end
