# frozen_string_literal: true

module IntelHex
  class Record
    class Eof < Record
      def self.type_id
        1
      end

      def self.type_name
        :eof
      end

      def self.type_data_length
        0
      end
    end

    def self.eof
      Eof.new
    end

    register_type(Eof)
  end
end
