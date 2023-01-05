class User < ApplicationRecord

  include PhoneNumberValidationConcern

  # to your hierarchical model
  has_closure_tree

  REFERRAL_ID_PREFIX = 'u'
  ACCOUNT_PREFIX = 'A'

  attr_accessor :invited_by

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  # enums
  enum role: {participant: 0, leader:1, root: 2}
  enum status: {active: 0, inactive: 1}

  # validations
  validates :name, :mobile, :country, :wallet_number, :time_zone, presence: true
  validates :read_agreement, acceptance: { accept: true }

  # custom validations
  validate :validate_refferal_id, on: :create

  # associations
  has_many :assurance_payments, -> { where(payment_type: :assurance) }, class_name: 'Payment'
  has_many :payments
  has_many :pay_ins
  has_many :pay_outs
  has_many :wallets

  # callbacks
  before_create :assign_parent
  after_create :make_leader
  after_create :create_wallets

  # scopes
  scope :except_roots, -> { where.not(id: User.root.ids) }

  def maximum_paid_in_amount(currency)
    self.payments.send(currency).pay_in.maximum(:amount).to_i
  end

  # start: payout calculation

  def wallet_balance(currency)
    self.wallets.send(currency.downcase).first.amount
  end

  def total_referral_bonus_amount
    self.payments.referral_bonus.pending
        .inner_join_with_referral_bonus
        .where('referral_bonus.status=?', ReferralBonus.statuses[:active])
        .sum(:amount)
  end

  def get_welcome_bonus(principal_amount)
    return 0.0 if self.pay_outs.count > 1

    Utilities::Calculator.calculate_interest(principal_amount, PayOut::WELCOME_BONUS)
  end

  def first_unlocked_pay_in_with_no_pay_out
    self.pay_ins.with_no_pay_outs.unlocked.order(:created_at).first
  end

  # end: payout calculation

  private

    def validate_refferal_id
      if self.invited_by.blank? || User.find_by(id: referral_id).blank?
        self.errors.add(:invited_by, 'Invalid referral id')
      end
    end

    def assign_parent
      parent = User.find_by(id: referral_id)
      self.parent = parent
    end

    def make_leader
      # check if parent can be a leader
      self.parent.leader! if self.parent&.children&.count == 15
    end

    def referral_id
      return nil if self.invited_by.blank?
      self.invited_by.gsub(User::REFERRAL_ID_PREFIX, '')
    end

    def create_wallets
      Wallet.currencies.each_key do |key|
        self.wallets.new.send("#{key}!")
      end
    end

    # end of private

end
