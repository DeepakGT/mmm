module OperationUtils
  module Exceptions
    class BaseError < StandardError
      attr_reader :errors

      def initialize(errors)
        @errors = [*errors]
      end

      def message
        @errors.join(", ")
      end
    end
  end
end
