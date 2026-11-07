# frozen_string_literal: true
# typed: strict

module IntelHex
  class Record
    class Data < Record
      sig { override.returns(Integer) }
      def self.type_id
        0
      end

      sig { override.returns(Symbol) }
      def self.type_name
        :data
      end

      sig { override.returns(T::Range[Integer]) }
      def self.type_data_length
        (1..255)
      end

      sig { override.returns(T::Array[Integer]) }
      def value
        data
      end

      sig { returns(String) }
      def value_s
        data_string = data.map { |b| format("%02x", b) }.join(" ")

        "[#{data_string}]"
      end
    end

    sig { params(data: T::Array[Integer]).returns(Data) }
    def self.data(data = [])
      record = Data.new
      record.data = data
      record
    end

    register_type(Data)
  end
end
