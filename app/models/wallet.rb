class Wallet < ApplicationRecord
  include HasCurrency
  belongs_to :user
end
