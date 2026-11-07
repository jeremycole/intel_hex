# frozen_string_literal: true
# typed: strict

module IntelHex
  class Record
    class ValueRecordUint16 < Record
      extend T::Sig
      extend T::Helpers

      abstract!

      sig { override.returns(Integer) }
      def self.type_data_length
        2
      end

      # Retrieve the 16-bit unsigned integer value from the record.
      sig { override.returns(Integer) }
      def value
        (T.must(data[0]) << 8) | T.must(data[1])
      end

      # Store a 32-bit unsigned integer value in the record.
      sig { params(value: Integer).void }
      def value=(value)
        data[0..1] = [
          (value & 0xff00) >> 8,
          value & 0x00ff,
        ]
        @length = data.size
        @checksum = recalculate_checksum
      end
    end
  end
end
