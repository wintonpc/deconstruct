require 'destructure'

describe 'destructure' do
  it 'matches stuff' do
    result = destructure([1, 2, 3]) do
      case
      when match { [1, x] }
        raise "oops"
      when match { [1, x, 3] }
        {x: x}
      when match { [1, x, 4] }
        raise "oops"
      else
        raise "oops"
      end
    end

    expect(result).to eql ({x: 2})
  end

  it 'can raise on failure, if asked' do
    expect { destructure(5, :or_raise) { match { 6 } } }.to raise_error Destructure::NoMatchError, /Failed to match 5/
  end

  it 'can compose patterns' do
    a_literal = DMatch::SexpTransformer.transform(proc { :int | :float | :str })
    a_literal
  end

  it 'is transparent' do
    # Verify the destructure block can call methods (including keywords)
    # and access local variables.
    cake = 'icing'
    result = destructure([1, 2, 3]) do
      case
      when match { [1, x, 3] }
        package(x, extra: cake)
      end
    end

    expect(result).to eql ({packaged: 2, extra: 'icing'})
  end

  it 'should handle unquoted values' do
    foo = 7
    @my_var = 9

    expect(destructure(5) { match { !5 } }).to eql true
    expect(destructure(7) { match { !foo } }).to eql true
    expect(destructure(9) { match { !@my_var } }).to eql true
  end

  it 'should handle unquoted patterns' do
    a_literal = DMatch::SexpTransformer.transform(proc { :int | :float | :str })
    expect(destructure([:float, 3.14]) do
      if match { [!a_literal, val] }
        val
      end
    end).to eql 3.14
  end

  it 'allows unquoted values to change between calls' do
    log = []
    local = 0
    p = proc { !local }

    destructure(0) { log << match(&p) }
    destructure(1) { log << match(&p) }
    local = 1
    destructure(0) { log << match(&p) }
    destructure(1) { log << match(&p) }
    expect(log).to eql [true, false, false, true]
  end

  it 'allows multiple procs per line' do
    expect(destructure(5) { match { !5 } }).to eql true
  end

  it 'external methods calls when unbound' do
    destructure(5) do
      package(42)
    end
  end

  it 'can shadow local variables' do
    v = 5
    result = destructure([1, 2]) do
      if match { [1, v] }
        v
      end
    end
    expect(result).to eql 2
  end

  it 'matches nested constants' do
    obj = DMatch::Var.new(:foo)
    destructure(obj, :or_raise) { match { DMatch::Var } }
    destructure(obj, :or_raise) { match { ::DMatch::Var } }
    destructure(obj, :or_raise) { match { DMatch::Var[name: :foo] } }
    destructure(obj, :or_raise) { match { ::DMatch::Var[name: :foo] } }
    expect { destructure(obj, :or_raise) { match { ::DMatch::Var[name: :bar] } } }.to raise_error Destructure::NoMatchError
  end

  def package(v, extra: nil)
    {packaged: v, extra: extra}
  end
end