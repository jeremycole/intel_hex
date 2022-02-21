# frozen_string_literal: true

module IntelHex
  class Record
    class ValueRecordUint16 < Record
      def self.type_data_length
        2
      end

      def value
        data_to_uint16
      end

      def data_to_uint16(offset = 0)
        (data[offset + 0] << 8) | data[offset + 1]
      end

      def uint16_to_data(value, offset = 0)
        data[(offset...(offset + 2))] = [
          (value & 0xff00) >> 8,
          value & 0x00ff,
        ]
        @length = data.size
        @checksum = recalculate_checksum
      end
    end
  end
end
