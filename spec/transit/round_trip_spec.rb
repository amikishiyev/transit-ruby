require 'spec_helper'

def round_trip(obj, type)
  io = StringIO.new('', 'w+')
  Transit::Writer.new(io, type).write(obj)
  reader = Transit::Reader.new(type)
  reader.read(StringIO.new(io.string))
end

def round_trips(label, obj, type)
  it "round trips #{label}" do
    if Time === obj
      # Our format truncates down to millis, which to_i gives us
      assert { round_trip(obj, type).to_i == obj.to_i }
    else
      assert { round_trip(obj, type) == obj }
    end
  end
end

module Transit

  shared_examples "round trips" do |type|
    round_trips("nil", nil, type)
    round_trips("a keyword", :foo, type)
    round_trips("a string", "this string", type)
    round_trips("a string starting with ~", "~this string", type)
    round_trips("true", true, type)
    round_trips("false", false, type)
    round_trips("an int", 1, type)
    round_trips("a long", 123456789012345, type)
    round_trips("a float", 1234.56, type)
    round_trips("a bigdec", BigDecimal.new("123.45"), type)
    round_trips("an instant (Time)", Time.now.utc, type)
    round_trips("a uuid", UUID.new, type)
    round_trips("a uri (url)", URI("http://example.com"), type)
    round_trips("a uri (file)", URI("file:///path/to/file.txt"), type)
    round_trips("a bytearray", ByteArray.new("abcdef\n\r\tghij"), type)
    round_trips("a TransitSymbol", TransitSymbol.new("abc"), type)
    round_trips("a list", TransitList.new([1,2,3]), type)
    round_trips("a hash w/ stringable keys", {"this" => "~hash", "1" => 2}, type)
    round_trips("a set", Set.new([1,2,3]), type)
    round_trips("an array", [1,2,3], type)
    round_trips("an array of ints", TypedArray.new("ints", [1,2,3]), type)
    round_trips("an array of longs", TypedArray.new("longs", [1,2,3]), type)
    round_trips("an array of floats", TypedArray.new("floats", [1.1,2.2,3.3]), type)
    round_trips("an array of floats", TypedArray.new("doubles", [1.1,2.2,3.3]), type)
    round_trips("an array of floats", TypedArray.new("bools", [true,false,false,true]), type)
    round_trips("a char", Char.new("x"), type)
    #      round_trips("an extension scalar", nil, type)
    #      round_trips("an extension struct", nil, type)
    round_trips("a hash with simple values", {'a' => 1, 'b' => 2, 'name' => 'russ'}, type)
    round_trips("a hash with TransitSymbols", {TransitSymbol.new("foo") => TransitSymbol.new("bar")}, type)
  end

  describe "Transit using json" do
    include_examples "round trips", :json
  end
end
