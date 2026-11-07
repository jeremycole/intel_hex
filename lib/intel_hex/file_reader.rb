# frozen_string_literal: true
# typed: strict

module IntelHex
  class FileReader
    extend T::Sig

    sig { returns(Integer) }
    attr_reader :address_base

    sig { returns(Integer) }
    attr_reader :address_mask

    sig { params(filename: String).void }
    def initialize(filename)
      @filename = filename
      @address_base = T.let(0, Integer)
      @address_mask = T.let(0xffff, Integer)
    end

    sig { params(block: T.nilable(T.proc.params(arg0: Record).void)).returns(T.nilable(T::Enumerator[Record])) }
    def each_record(&block)
      return enum_for(:each_record) unless block_given?

      File.open(@filename, "r") do |file|
        file.each_line do |line|
          yield Record.parse(line.chomp)
        end
      rescue EOFError
        return nil
      end

      nil
    end

    sig { params(block: T.nilable(T.proc.params(arg0: Integer, arg1: Integer).void)).returns(T.nilable(T::Enumerator[[Integer, Integer]])) }
    def each_byte_with_address(&block)
      return enum_for(:each_byte_with_address) unless block_given?

      each_record do |record|
        if record.is_a?(Record::Data)
          record.each_byte_with_address
        elsif record.is_a?(Record::Esa)
          @address_base = record.value << 4   # bits 4..19 of address
          @address_mask = 0xfffff          # 20 bit address size
        elsif record.is_a?(Record::Ela)
          @address_base = record.value << 16  # bits 16..31 of address
          @address_mask = 0xffffffff          # 32 bit address size
        end
      end

      nil
    end
  end
end
