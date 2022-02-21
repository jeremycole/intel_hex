# frozen_string_literal: true

require "intel_hex/record/value_record_uint16"

module IntelHex
  class Record
    class Esa < ValueRecordUint16
      def initialize(length = 0, offset = 0, data = [], checksum = nil, line: nil, validate: false)
        super
      end

      def self.type_id
        2
      end

      def self.type_name
        :esa
      end

      alias esa data_to_uint16
      alias esa= uint16_to_data
    end

    def self.esa(value = nil)
      record = Esa.new
      record.esa = value if value
      record
    end

    register_type(Esa)
  end
end
