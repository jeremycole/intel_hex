# frozen_string_literal: true
# typed: strict

module IntelHex
  class Record
    class Eof < Record
      extend T::Sig

      sig { returns(Integer).override }
      def self.type_id
        1
      end

      sig { returns(Symbol).override }
      def self.type_name
        :eof
      end

      sig { returns(Integer).override }
      def self.type_data_length
        0
      end
    end

    sig { returns(Eof) }
    def self.eof
      Eof.new
    end

    register_type(Eof)
  end
end
