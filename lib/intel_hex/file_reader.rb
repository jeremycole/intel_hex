# frozen_string_literal: true

module IntelHex
  class FileReader
    def initialize(filename)
      @filename = filename
      @address_base = 0
      @address_mask = 0xffff
      @esa = 0
      @ssa = 0
      @ela = 0
      @sla = 0
    end

    def each_record
      return to_enum(:each_record) unless block_given?

      file = File.open(@filename, 'r')

      begin
        file.each_line do |line|
          yield Record.parse(line.chomp)
        end
      rescue EOFError
        return nil
      end

      nil
    end

    def each_byte_with_address
      return to_enum(:each_byte_with_address) unless block_given?

      each_record do |record|
        case record.type
        when :data
          record.each_byte_with_address do |byte, offset|
            yield byte, (@address_base + offset) & @address_mask
          end
        when :esa
          @esa = record.esa
          @address_base = @esa << 4   # bits 4..19 of address
          @address_mask = 0xfffff     # 20 bit address size
        when :ela
          @ela = record.ela
          @address_base = @ela << 16  # bits 16..31 of address
          @address_mask = 0xffffffff  # 32 bit address size
        end
      end

      nil
    end
  end
end
