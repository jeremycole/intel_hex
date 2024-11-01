# frozen_string_literal: true

require "intel_hex/record/value_record_uint16"

module IntelHex
  class Record
    class Esa < ValueRecordUint16
      def self.type_id
        2
      end

      def self.type_name
        :esa
      end
    end

    def self.esa(value = nil)
      record = Esa.new
      record.value = value if value
      record
    end

    register_type(Esa)
  end
end
