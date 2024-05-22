class FileIO < StringIO

  attr_reader :original_filename
  attr_reader :identifier

  def initialize(stream, filename)
    super(stream.to_s)
    @original_filename = filename
    @filename = filename
  end

  def read(...)
    rewind

    super(...)
  end

end
