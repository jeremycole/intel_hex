# frozen_string_literal: true

module IntelHex
  class Record
    class ValueRecordUint16 < Record
      def self.type_data_length
        2
      end

      # Retrieve the 16-bit unsigned integer value from the record.
      def value
        (data[0] << 8) | data[1]
      end

      # Store a 32-bit unsigned integer value in the record.
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
