module Etsy
  module V3
    class Response < BaseResponse
      def code
        @raw_response.status
      end

      def count
        return 1 unless paginated?

        hashed['results'].nil? ? 0 : hashed['results'].count
      end

      def success_result
        return hashed unless paginated?

        hashed['results'] || []
      end

      def total
        hashed['count']
      end

      def paginated?
        hashed.key?('count')
      end

      private

      def error_data
        parsed_data = JSON.parse(body)

        error_data_array =
          parsed_data
            .values_at('error', 'error_description')
            .compact

        return parsed_data if error_data_array.blank?

        error_data_array.join(', ')

      rescue JSON::ParserError
        body
      end

      def exceeded_overall_limit?
        code.to_s == '429'
      end

      def failed_response?
        super || !success?
      end
    end
  end
end
