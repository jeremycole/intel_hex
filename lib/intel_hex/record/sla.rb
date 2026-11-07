# frozen_string_literal: true
# typed: strict

require "intel_hex/record/value_record_uint32"

module IntelHex
  class Record
    class Sla < ValueRecordUint32
      extend T::Sig

      sig { override.returns(Integer) }
      def self.type_id
        5
      end

      sig { override.returns(Symbol) }
      def self.type_name
        :sla
      end
    end

    sig { params(value: T.nilable(Integer)).returns(Sla) }
    def self.sla(value = nil)
      record = Sla.new
      record.value = value if value
      record
    end

    register_type(Sla)
  end
end
