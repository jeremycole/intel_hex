# frozen_string_literal: true

require "intel_hex/record/value_record_uint32"

module IntelHex
  class Record
    class Ssa < ValueRecordUint32
      def self.type_id
        3
      end

      def self.type_name
        :ssa
      end
    end

    def self.ssa(value = nil)
      record = Ssa.new
      record.value = value if value
      record
    end

    register_type(Ssa)
  end
end
