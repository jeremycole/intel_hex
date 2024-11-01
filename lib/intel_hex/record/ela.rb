# frozen_string_literal: true

require "intel_hex/record/value_record_uint16"

module IntelHex
  class Record
    class Ela < ValueRecordUint16
      def self.type_id
        4
      end

      def self.type_name
        :ela
      end
    end

    def self.ela(value = nil)
      record = Ela.new
      record.value = value if value
      record
    end

    register_type(Ela)
  end
end
