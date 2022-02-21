# frozen_string_literal: true

require "intel_hex/record/value_record_uint32"

module IntelHex
  class Record
    class Ssa < ValueRecordUint32
      def initialize(length = 0, offset = 0, data = [], checksum = nil, line: nil, validate: false)
        super
      end

      def self.type_id
        3
      end

      def self.type_name
        :ssa
      end

      alias ssa data_to_uint32
      alias ssa= uint32_to_data
    end

    def self.ssa(value = nil)
      record = Ssa.new
      record.ssa = value if value
      record
    end

    register_type(Ssa)
  end
end
