module OperationUtils
  class ErrorTracker
    def initialize
      @error_array = []
    end

    def add_error(error_string)
      @error_array.push(error_string)
    end

    def add_errors(errors_array)
      @error_array << errors_array
    end

    def list_errors
      @error_array.flatten.compact
    end

    def any?
      list_errors.count > 0
    end

    def status
      any? ? :failure : :success
    end

    def success?
      status == :success
    end

    def failure?
      status == :failure
    end

    def none?
      !any?
    end
  end
end
