# frozen_string_literal: true
# typed: strict

module IntelHex
  class MisformattedFileError < RuntimeError; end

  class ValidationError < StandardError; end

  class InvalidTypeError < ValidationError; end

  class InvalidLengthError < ValidationError; end

  class InvalidOffsetError < ValidationError; end

  class InvalidDataError < ValidationError; end

  class InvalidChecksumError < ValidationError; end

  class Record
    extend T::Sig
    extend T::Helpers

    abstract!

    @type_by_id = T.let({}, T::Hash[Integer, T.class_of(Record)])
    @type_by_name = T.let({}, T::Hash[Symbol, T.class_of(Record)])

    class << self
      extend T::Sig
      extend T::Helpers

      abstract!

      sig { returns(T::Hash[Integer, T.class_of(Record)]) }
      attr_reader :type_by_id

      sig { returns(T::Hash[Symbol, T.class_of(Record)]) }
      attr_reader :type_by_name

      sig { params(type: T.class_of(Record)).void }
      def register_type(type)
        raise "Type name #{type.type_name} is not a symbol" unless type.type_name.is_a?(Symbol)
        raise "Type name #{type.type_name} redefined" if type_by_name.include?(type.type_name)
        raise "Type id #{type.type_id} redefined" if type_by_id.include?(type.type_id)

        type_by_id[type.type_id] = type_by_name[type.type_name] = type
      end

      sig { returns(Integer).abstract }
      def type_id; end

      sig { returns(Symbol).abstract }
      def type_name; end

      sig { returns(T.any(Integer, T::Range[Integer])).abstract }
      def type_data_length; end

      sig { params(line: String).returns(Record) }
      def parse(line)
        raise MisformattedFileError, "Expected ':' at start of line" unless line[0] == ":"
        raise MisformattedFileError, "Line length incorrect" unless line.size >= (1 + 2 + 4 + 2)

        length = T.must(line[1..2]).to_i(16)
        data_end = (9 + (length * 2))

        offset = T.must(line[3..6]).to_i(16)
        type_id = T.must(line[7..8]).to_i(16)
        data = T.must(line[9...data_end]).chars.each_slice(2).map { |a| a.join.to_i(16) }
        checksum = T.must(line[data_end..(data_end + 2)]).to_i(16)

        raise InvalidTypeError, "Unknown type #{type_id}" unless type_by_id.include?(type_id)

        type = type_by_id[type_id]
        T.must(type).new(length, offset, data, checksum, line: line, validate: true)
      end

      sig { params(subclass: T::Class[T.anything]).void }
      def inherited(subclass)
        super

        subclass.instance_eval { public_class_method :new }
      end
    end

    private_class_method :new

    sig { returns(Integer) }
    attr_reader :length

    sig { returns(Integer) }
    attr_reader :offset

    sig { returns(T::Array[Integer]) }
    attr_reader :data

    sig { returns(T.nilable(Integer)) }
    attr_reader :checksum

    sig { returns(T.nilable(String)) }
    attr_reader :line

    sig do
      params(
        length: Integer,
        offset: Integer,
        data: T::Array[Integer],
        checksum: T.nilable(Integer),
        line: T.nilable(String),
        validate: T::Boolean
      ).void
    end
    def initialize(length = 0, offset = 0, data = [], checksum = nil, line: nil, validate: false)
      @length = length
      @offset = offset
      @data = data
      @calculated_checksum = T.let(nil, T.nilable(Integer))
      @checksum = T.let(checksum || calculate_checksum, T.nilable(Integer))
      @line = line

      self.validate if validate
    end

    sig { returns(Integer) }
    def type_id
      self.class.type_id
    end

    sig { returns(Symbol) }
    def type_name
      self.class.type_name
    end

    alias type type_name

    sig { returns(T.any(Integer, T::Range[Integer])) }
    def type_data_length
      self.class.type_data_length
    end

    sig { params(value: T::Array[Integer]).void }
    def data=(value)
      raise InvalidLengthError, "Data length #{value.size} too large" unless value.size <= 255

      @data = value
      @length = data.size
      @checksum = recalculate_checksum
    end

    sig { returns(T.nilable(T.any(Integer, T::Array[Integer]))) }
    def value; end

    sig { returns(String) }
    def value_s
      value.to_s
    end

    sig { returns(String) }
    def to_s
      type_value = "#{type}=#{value_s}"
      "#<#{self.class.name} type=#{type_name} offset=#{offset} length=#{length} #{type_value}>"
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h
      {
        type: type,
        offset: offset,
        length: length,
        checksum: checksum,
      }.merge({ type => value })
    end

    sig { returns(String) }
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

    sig { returns(Integer) }
    def calculate_checksum
      return @calculated_checksum if @calculated_checksum

      sum = length + ((offset & 0xff00) >> 8) + (offset & 0x00ff) + type_id
      sum += data.sum

      @calculated_checksum = (((sum & 0xff) ^ 0xff) + 1) & 0xff
    end

    sig { returns(Integer) }
    def recalculate_checksum
      @calculated_checksum = nil
      calculate_checksum
    end

    sig { returns(T::Boolean) }
    def valid?
      validate
      true
    rescue ValidationError
      false
    end

    sig { returns(T::Boolean) }
    def validate # rubocop:disable Naming/PredicateMethod
      validate_length
      validate_offset
      validate_data
      validate_checksum

      true # We'll raise an exception if validation fails.
    end

    sig { void }
    def validate_offset
      raise InvalidOffsetError, "Offset #{offset} is negative" unless offset >= 0
      raise InvalidOffsetError, "Offset #{offset} is too large" unless offset < 65_536
    end

    sig { void }
    def validate_length
      tdl = type_data_length

      if tdl.is_a?(Integer)
        return if length == tdl
      elsif tdl.is_a?(Range)
        return if tdl.include?(length)
      end

      raise InvalidLengthError, "Length for type #{type} must be #{tdl}; #{length} given"
    end

    sig { void }
    def validate_data
      return if data.size == length

      raise InvalidDataError, "Data length #{data.size} does not match length #{length}"
    end

    sig { void }
    def validate_checksum
      return if calculate_checksum == checksum

      raise InvalidChecksumError, "Checksum value #{checksum} does not match expected checksum #{calculate_checksum}"
    end

    sig { params(blk: T.untyped).returns(T.nilable(T::Enumerator[T.untyped])) }
    def each_byte_with_address(&blk)
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
