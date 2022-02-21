# frozen_string_literal: true

require "intel_hex/record/value_record_uint16"

module IntelHex
  class Record
    class Ela < ValueRecordUint16
      def initialize(length = 0, offset = 0, data = [], checksum = nil, line: nil, validate: false)
        super
      end

      def self.type_id
        4
      end

      def self.type_name
        :ela
      end

      alias ela data_to_uint16
      alias ela= uint16_to_data
    end

    def self.ela(value = nil)
      record = Ela.new
      record.ela = value if value
      record
    end

    register_type(Ela)
  end
end
