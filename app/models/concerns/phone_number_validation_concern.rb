module PhoneNumberValidationConcern
  extend ActiveSupport::Concern
  
  included do
    before_save :normalize_phone
    validates :mobile, phone: true, allow_blank: true
  end

  def formatted_phone
    parsed_phone = Phonelib.parse(mobile)
    return mobile if parsed_phone.invalid?

    formatted =
      if parsed_phone.country_code == "1" # NANP
        parsed_phone.full_national # (415) 555-2671;123
      else
        parsed_phone.full_international # +44 20 7183 8750
      end
    formatted.gsub!(";", " x") # (415) 555-2671 x123
    formatted
  end

  private

    def normalize_phone
      self.mobile = Phonelib.parse(mobile).full_e164.presence
    end

  # end of private
end
