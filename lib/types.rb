require 'singleton'

class Var
  attr_reader :name

  def initialize(name=nil, &pred)
    @name = name
    @pred = pred
  end

  def test(x)
    @pred == nil ? true : @pred.call(x)
  end
end

class Splat < Var

end

class Obj
  attr_reader :fields

  def initialize(fields={}, &pred)
    @fields = fields
    @pred = pred
  end

  def test(x)
    @pred == nil ? true : @pred.call(x)
  end
end

class Pred
  def initialize(&pred)
    @pred = pred
  end

  def test(x)
    @pred.call(x)
  end
end