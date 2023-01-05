module OperationUtils
  module OperationResponseBuilder
    class << self
      def call(result, error_tracker)
        {
          status: error_tracker.status,
          errors: error_tracker.list_errors,
          result: result
        }
      end
    end
  end
end
