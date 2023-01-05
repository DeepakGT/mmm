class Support::Ticket < ApplicationRecord
  belongs_to :user, optional: true

  enum status: {'pending': 0, 'blocked': 1, 'resolved': 2}

  validates :email, :subject, :message, presence: true
end
