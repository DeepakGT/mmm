module LogNotifierService
  class << self
    def call(error)
      Rails.logger.error "LogNotifierService message: #{error}"
      if error.respond_to?(:backtrace)
        Rails.logger.error error.backtrace.join("\n")
      end
    end
  end
end
