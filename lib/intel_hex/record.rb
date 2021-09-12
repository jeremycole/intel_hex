# frozen_string_literal: true

module IntelHex
  class MisformattedFileError < RuntimeError; end

  class ValidationError < StandardError; end

  class InvalidTypeError < ValidationError; end

  class InvalidLengthError < ValidationError; end

  class InvalidOffsetError < ValidationError; end

  class InvalidDataError < ValidationError; end

  class InvalidChecksumError < ValidationError; end

  class Record
    TYPES = %i[
      data
      eof
      esa
      ssa
      ela
      sla
    ].freeze

    TYPE_MAP = TYPES.each_with_index.each_with_object({}) { |(k, i), h| h[k] = i }

    TYPE_DATA_LENGTH = {
      data: (1..255),
      eof: 0,
      esa: 2,
      ssa: 4,
      ela: 2,
      sla: 4,
    }.freeze

    def self.parse(line)
      raise MisformattedFileError, 'Expected \':\' at start of line' unless line[0] == ':'
      raise MisformattedFileError, 'Line length incorrect' unless line.size >= (1 + 2 + 4 + 2)

      length = line[1..2].to_i(16)
      data_end = (9 + length * 2)

      offset = line[3..6].to_i(16)
      type = TYPES[line[7..8].to_i(16)]
      data = line[9...data_end].chars.each_slice(2).map { |a| a.join.to_i(16) }
      checksum = line[data_end..(data_end + 2)].to_i(16)

      Record.new(type, length, offset, data, checksum, line: line, validate: true)
    end

    def self.data(data)
      record = Record.new(:data)
      record.data = data
      record
    end

    def self.eof
      Record.new(:eof)
    end

    def self.type_with_value(type, value)
      record = Record.new(type)
      record.send("#{type}=".to_sym, value)
      record
    end

    def self.esa(value)
      type_with_value(:esa, value)
    end

    def self.ssa(value)
      type_with_value(:ssa, value)
    end

    def self.ela(value)
      type_with_value(:ela, value)
    end

    def self.sla(value)
      type_with_value(:sla, value)
    end

    attr_reader :length, :offset, :type, :data, :checksum, :line

    # rubocop:disable Metrics/ParameterLists
    def initialize(type, length = 0, offset = 0, data = [], checksum = nil, line: nil, validate: false)
      @type = type
      @length = length
      @offset = offset
      @data = data
      @calculated_checksum = nil
      @checksum = checksum || calculate_checksum
      @line = line

      self.validate if validate
    end
    # rubocop:enable Metrics/ParameterLists

    def data_s
      "[#{data.map { |b| '%02x' % b }.join(' ')}]"
    end

    def value_s
      return '' if type == :eof

      "#{type}=#{type == :data ? data_s : send(type)}"
    end

    def to_s
      "#<#{self.class.name} type=#{type} offset=#{offset} length=#{length} #{value_s}>"
    end

    def to_ascii
      ':%02X%04X%02X%s%02X' % [
        length,
        offset,
        TYPE_MAP[type],
        data.map { |b| '%02X' % b }.join,
        checksum,
      ]
    end

    def calculate_checksum
      return @calculated_checksum if @calculated_checksum

      sum = length + ((offset & 0xff00) >> 8) + (offset & 0x00ff) + TYPE_MAP[type]
      sum += data.sum

      @calculated_checksum = (((sum & 0xff) ^ 0xff) + 1) & 0xff
    end

    def recalculate_checksum
      @calculated_checksum = nil
      calculate_checksum
    end

    def valid?
      validate
      true
    rescue ValidationError
      false
    end

    def validate
      validate_type
      validate_length
      validate_offset
      validate_data
      validate_checksum
    end

    def validate_type
      return if TYPE_MAP.include?(type)

      raise InvalidTypeError, "Type #{type} is invalid"
    end

    def validate_offset
      raise InvalidOffsetError, "Offset #{offset} is negative" unless offset >= 0
      raise InvalidOffsetError, "Offset #{offset} is too large" unless offset < 2**16
    end

    def validate_length
      valid_length = TYPE_DATA_LENGTH[type]

      case valid_length
      when Integer
        return if length == valid_length
      when Range
        return if valid_length.include?(length)
      end

      raise InvalidLengthError, "Length for type #{type} must be #{valid_length}; #{length} given"
    end

    def validate_data
      return if data.size == length

      raise InvalidDataError, "Data length #{data.size} does not match length #{length}"
    end

    def validate_checksum
      return if calculate_checksum == checksum

      raise InvalidChecksumError, "Checksum value #{checksum} does not match expected checksum #{calculate_checksum}"
    end

    def each_byte_with_address
      return Enumerator.new(self, :each_byte_with_address) unless block_given?

      data.each_with_index do |byte, i|
        yield byte, offset + i
      end

      nil
    end

    def data=(value)
      raise 'Incorrect data type' unless value.is_a?(Array)
      raise InvalidLengthError, "Data length #{value.size} too large" unless value.size <= 255

      @data = value
      @length = data.size
      @checksum = recalculate_checksum
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

    alias esa data_to_uint16
    alias ssa data_to_uint32
    alias ela data_to_uint16
    alias sla data_to_uint32

    alias esa= uint16_to_data
    alias ssa= uint32_to_data
    alias ela= uint16_to_data
    alias sla= uint32_to_data
  end
end
