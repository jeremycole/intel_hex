module IntelHex
  class MisformattedFileError < RuntimeError; end
  class InvalidTypeError < RuntimeError; end
  class InvalidLengthError < RuntimeError; end
  class InvalidOffsetError < RuntimeError; end
  class InvalidDataError < RuntimeError; end
  class InvalidChecksumError < RuntimeError; end

  class Record
    TYPES = [
      :data,
      :eof,
      :esa,
      :ssa,
      :ela,
      :sla,
    ]

    TYPE_MAP = TYPES.each_with_index.inject({}) { |h, (k, i)| h[k] = i; h }
  
    TYPE_DATA_LENGTH = {
      data: (1..255),
      eof: 0,
      esa: 2,
      ssa: 4,
      ela: 2,
      sla: 4,
    }

    def self.parse(line)
      raise MisformattedFileError.new("Expected ':' at start of line") unless line[0] == ':'
      raise MisformattedFileError.new("Line length incorrect") unless line.size >= (1 + 2 + 4 + 2)

      length = line[1..2].to_i(16)
      data_end = (9 + length*2)

      offset = line[3..6].to_i(16)
      type = TYPES[line[7..8].to_i(16)]
      data = line[9...data_end].split('').each_slice(2).map { |a| a.join.to_i(16) }
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
      record.send((type.to_s + '=').to_sym, value)
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

    attr_reader :length
    attr_reader :offset
    attr_reader :type
    attr_reader :data
    attr_reader :checksum
    attr_reader :line

    def initialize(type, length = 0, offset = 0, data = [], checksum=nil, line: nil, validate: false)
      @type = type
      @length = length
      @offset = offset
      @data = data
      @calculated_checksum = nil
      @checksum = checksum || calculate_checksum
      @line = line

      self.validate if validate
    end

    def to_s
      "#<#{self.class.name} type=#{type} offset=#{offset} length=#{length}>"
    end

    def to_ascii
      ":%02X%04X%02X%s%02X" % [
        length,
        offset,
        TYPE_MAP[type],
        data.map { |b| "%02X" % b }.join,
        checksum,
      ]
    end

    def calculate_checksum
      return @calculated_checksum if @calculated_checksum

      sum = length + ((offset & 0xff00) >> 8) + (offset & 0x00ff) + TYPE_MAP[type]
      sum += data.inject(0) { |s, n| s += n; s }

      @calculated_checksum = (((sum & 0xff) ^ 0xff) + 1) & 0xff
    end

    def recalculate_checksum
      @calculated_checksum = nil
      calculate_checksum
    end

    def valid?
      begin
        validate
        return true
      rescue
        return false
      end
    end

    def validate
      validate_type
      validate_length
      validate_offset
      validate_data
      validate_checksum
    end

    def validate_type
      raise InvalidTypeError.new("Type #{type} is invalid") unless TYPE_MAP.include?(type)
    end

    def validate_offset
      raise InvalidOffsetError.new("Offset #{offset} is negative") unless offset >= 0
      raise InvalidOffsetError.new("Offset #{offset} is too large") unless offset < 2**16
    end

    def validate_length
      valid_length = TYPE_DATA_LENGTH[type]

      case valid_length
      when Integer
        return if length == valid_length
      when Range
        return if valid_length.include?(length)
      end

      raise InvalidLengthError.new("Length for type #{type} must be #{valid_length}; #{length} given") 
    end

    def validate_data
      raise InvalidDataError.new("Data length #{data.size} does not match length #{length}") unless data.size == length
    end

    def validate_checksum
      raise InvalidChecksumError.new("Checksum value #{checksum} does not match expected checksum #{calculate_checksum}") unless calculate_checksum == checksum
    end

    def each_byte_with_address
      return Enumerator.new(self, :each_byte_with_address) unless block_given?
  
      data.each_with_index do |byte, i|
        yield byte, offset + i
      end

      nil
    end

    def data=(value)
      raise "Incorrect data type" unless value.is_a?(Array)
      raise InvalidLengthError.new("Data length #{value.size} too large") unless value.size <= 255
      @data = value
      @length = data.size
      @checksum = recalculate_checksum
      nil
    end

    def data_to_uint16(offset = 0)
      (data[offset + 0] << 8) | data[offset + 1]
    end

    def uint16_to_data(value, offset = 0)
      self.data[(offset...(offset+2))] = [
        (value & 0xff00) >> 8,
        value & 0x00ff
      ]
      @length = data.size
      @checksum = recalculate_checksum
    end

    def data_to_uint32(offset = 0)
      (data[offset + 0] << 24) | (data[offset + 1] << 16) | (data[offset + 2] << 8) | data[offset + 3]
    end

    def uint32_to_data(value, offset = 0)
      self.data[(offset...(offset+4))] = [
        (value & 0xff000000) >> 24,
        (value & 0x00ff0000) >> 16,
        (value & 0x0000ff00) >> 8,
        value & 0x000000ff
      ]
      @length = data.size
      @checksum = recalculate_checksum
    end

    alias_method :esa, :data_to_uint16
    alias_method :ssa, :data_to_uint32
    alias_method :ela, :data_to_uint16
    alias_method :sla, :data_to_uint32

    alias_method :esa=, :uint16_to_data
    alias_method :ssa=, :uint32_to_data
    alias_method :ela=, :uint16_to_data
    alias_method :sla=, :uint32_to_data
  end
end