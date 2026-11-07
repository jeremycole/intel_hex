# frozen_string_literal: true
# typed: strict

module IntelHex
  class Record
    class ValueRecordUint32 < Record
      extend T::Sig
      extend T::Helpers

      abstract!

      sig { override.returns(Integer) }
      def self.type_data_length
        4
      end

      # Retrieve the 32-bit unsigned integer value from the record.
      sig { override.returns(Integer) }
      def value
        (T.must(data[0]) << 24) | (T.must(data[1]) << 16) | (T.must(data[2]) << 8) | T.must(data[3])
      end

      # Store a 32-bit unsigned integer value in the record.
      sig { params(value: Integer).void }
      def value=(value)
        data[0..3] = [
          (value & 0xff000000) >> 24,
          (value & 0x00ff0000) >> 16,
          (value & 0x0000ff00) >> 8,
          value & 0x000000ff,
        ]
        @length = data.size
        @checksum = recalculate_checksum
      end
    end
  end
end
