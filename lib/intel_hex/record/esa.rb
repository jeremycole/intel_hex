# frozen_string_literal: true
# typed: strict

require "intel_hex/record/value_record_uint16"

module IntelHex
  class Record
    class Esa < ValueRecordUint16
      extend T::Sig

      sig { override.returns(Integer) }
      def self.type_id
        2
      end

      sig { override.returns(Symbol) }
      def self.type_name
        :esa
      end
    end

    sig { params(value: T.nilable(Integer)).returns(Esa) }
    def self.esa(value = nil)
      record = Esa.new
      record.value = value if value
      record
    end

    register_type(Esa)
  end
end
