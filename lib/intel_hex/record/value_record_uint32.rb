# frozen_string_literal: true

module IntelHex
  class Record
    class ValueRecordUint32 < Record
      def self.type_data_length
        4
      end

      def value
        data_to_uint32
      end

      def data_to_uint32(offset = 0)
        (data[offset + 0] << 24) | (data[offset + 1] << 16) | (data[offset + 2] << 8) | data[offset + 3]
      end

      def uint32_to_data(value, offset = 0)
        data[(offset...(offset + 4))] = [
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
