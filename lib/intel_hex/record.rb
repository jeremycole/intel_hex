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
    class << self
      def register_type(type)
        @type_by_id ||= {}
        @type_by_name ||= {}

        raise "Type name #{type.type_name} is not a symbol" unless type.type_name.is_a?(Symbol)
        raise "Type name #{type.type_name} redefined" if @type_by_name.include?(type.type_name)
        raise "Type id #{type.type_id} redefined" if @type_by_id.include?(type.type_id)

        @type_by_id[type.type_id] = @type_by_name[type.type_name] = type
      end

      attr_reader :type_by_id, :type_by_name

      def type_id
        raise NotImplementedError
      end

      def type_name
        raise NotImplementedError
      end

      def type_data_length
        raise NotImplementedError
      end

      def parse(line)
        raise MisformattedFileError, "Expected ':' at start of line" unless line[0] == ":"
        raise MisformattedFileError, "Line length incorrect" unless line.size >= (1 + 2 + 4 + 2)

        length = line[1..2].to_i(16)
        data_end = (9 + (length * 2))

        offset = line[3..6].to_i(16)
        type_id = line[7..8].to_i(16)
        data = line[9...data_end].chars.each_slice(2).map { |a| a.join.to_i(16) }
        checksum = line[data_end..(data_end + 2)].to_i(16)

        raise InvalidTypeError, "Unknown type #{type_id}" unless type_by_id.include?(type_id)

        type = type_by_id[type_id]
        type.new(length, offset, data, checksum, line: line, validate: true)
      end

      def inherited(subclass)
        super

        subclass.instance_eval { public_class_method :new }
      end
    end

    private_class_method :new

    attr_reader :length, :offset, :data, :checksum, :line

    def initialize(length = 0, offset = 0, data = [], checksum = nil, line: nil, validate: false)
      @length = length
      @offset = offset
      @data = data
      @calculated_checksum = nil
      @checksum = checksum || calculate_checksum
      @line = line

      self.validate if validate
    end

    def type_id
      self.class.type_id
    end

    def type_name
      self.class.type_name
    end

    alias type type_name

    def type_data_length
      self.class.type_data_length
    end

    def data=(value)
      raise InvalidDataError, "Incorrect data type" unless value.is_a?(Array)
      raise InvalidLengthError, "Data length #{value.size} too large" unless value.size <= 255

      @data = value
      @length = data.size
      @checksum = recalculate_checksum
    end

    def value
      nil
    end

    def value_s
      value.to_s
    end

    def to_s
      type_value = value ? "#{type}=#{value_s}" : ""
      "#<#{self.class.name} type=#{type_name} offset=#{offset} length=#{length} #{type_value}>"
    end

    def to_h
      {
        type: type,
        offset: offset,
        length: length,
        checksum: checksum,
      }.merge({ type => value })
    end

    def to_ascii
      format(
        ":%02X%04X%02X%s%02X",
        length,
        offset,
        type_id,
        data.map { |b| format("%02X", b) }.join,
        checksum
      )
    end

    def calculate_checksum
      return @calculated_checksum if @calculated_checksum

      sum = length + ((offset & 0xff00) >> 8) + (offset & 0x00ff) + type_id
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
      validate_length
      validate_offset
      validate_data
      validate_checksum
    end

    def validate_offset
      raise InvalidOffsetError, "Offset #{offset} is negative" unless offset >= 0
      raise InvalidOffsetError, "Offset #{offset} is too large" unless offset < 2**16
    end

    def validate_length
      case type_data_length
      when Integer
        return if length == type_data_length
      when Range
        return if type_data_length.include?(length)
      else
        raise InvalidTypeError, "Length for type #{type} is unhandled by validation"
      end

      raise InvalidLengthError, "Length for type #{type} must be #{type_data_length}; #{length} given"
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
      return enum_for(:each_byte_with_address) unless block_given?

      data.each_with_index do |byte, i|
        yield byte, offset + i
      end

      nil
    end
  end
end

require "intel_hex/record/data"
require "intel_hex/record/eof"
require "intel_hex/record/esa"
require "intel_hex/record/ssa"
require "intel_hex/record/ela"
require "intel_hex/record/sla"
