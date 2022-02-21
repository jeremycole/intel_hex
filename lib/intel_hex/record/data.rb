# frozen_string_literal: true

module IntelHex
  class Record
    class Data < Record
      def initialize(length = 0, offset = 0, data = [], checksum = nil, line: nil, validate: false)
        super
      end

      def self.type_id
        0
      end

      def self.type_name
        :data
      end

      def self.type_data_length
        (1..255)
      end

      def value
        data
      end

      def value_s
        data_string = data.map { |b| format("%02x", b) }.join(" ")

        "[#{data_string}]"
      end
    end

    def self.data(data = [])
      record = Data.new
      record.data = data
      record
    end

    register_type(Data)
  end
end
