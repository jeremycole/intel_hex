# frozen_string_literal: true

require "intel_hex/record/value_record_uint32"

module IntelHex
  class Record
    class Sla < ValueRecordUint32
      def self.type_id
        5
      end

      def self.type_name
        :sla
      end
    end

    def self.sla(value = nil)
      record = Sla.new
      record.value = value if value
      record
    end

    register_type(Sla)
  end
end
