ActiveAdmin.register Payment do
  config.batch_actions = false

  actions :index, :show, :edit, :update

  permit_params :transaction_id, :status

  after_update :complete_transaction

  form do |f|
    f.semantic_errors *f.object.errors.keys
    inputs 'Complete the payment' do
      input :transaction_id
      input :status, include_blank: false
    end
    actions
  end

  show do
    attributes_table do
      row :amount
      row :currency
      row :payment_type
      row :status
      row :receiver_wallet_number
      row :wallet_holder_name
      row :transaction_id
      row :activity do |payment|
        link_to "PayIn ##{payment.activity_id}", admin_pay_in_path(payment.activity_id) if payment.pay_in?
        link_to "PayOut ##{payment.activity_id}", admin_pay_out_path(payment.activity_id) if payment.pay_out?
        link_to "ReferralBonus ##{payment.activity_id}", admin_referral_bonus_path(payment.activity_id) if payment.referral_bonus?
      end
      row :user
      row :paid_at
      row :created_at
      row :updated_at
    end
  end

  controller do

    def complete_transaction(obj)
      return if !obj.pay_out? || !obj.complete?

      complete_referral_bonus_payments(obj)
      obj.pay_out.complete!
      obj.pay_out.pay_in.settled!
    end

    private

      def complete_referral_bonus_payments(obj)
        obj.user.payments.referral_bonus.pending
            .inner_join_with_referral_bonus
            .where('referral_bonus.status=?', ReferralBonus.statuses[:active]).each do |payment|
              payment.transaction_id = obj.transaction_id
              payment.complete!
            end
      end
    
      # end of private
  end
end