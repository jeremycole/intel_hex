# frozen_string_literal: true
# typed: strict

require "intel_hex/record/value_record_uint16"

module IntelHex
  class Record
    class Ela < ValueRecordUint16
      extend T::Sig

      sig { override.returns(Integer) }
      def self.type_id
        4
      end

      sig { override.returns(Symbol) }
      def self.type_name
        :ela
      end
    end

    sig { params(value: T.nilable(Integer)).returns(Ela) }
    def self.ela(value = nil)
      record = Ela.new
      record.value = value if value
      record
    end

    register_type(Ela)
  end
end
