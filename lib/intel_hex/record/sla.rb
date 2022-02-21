# frozen_string_literal: true

require "intel_hex/record/value_record_uint32"

module IntelHex
  class Record
    class Sla < ValueRecordUint32
      def initialize(length = 0, offset = 0, data = [], checksum = nil, line: nil, validate: false)
        super
      end

      def self.type_id
        5
      end

      def self.type_name
        :sla
      end

      alias sla data_to_uint32
      alias sla= uint32_to_data
    end

    def self.sla(value = nil)
      record = Sla.new
      record.sla = value if value
      record
    end

    register_type(Sla)
  end
end
