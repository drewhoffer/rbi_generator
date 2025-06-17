class MyTest
  sig { void }
  def hello; end

  sig { params(x: T.untyped).returns(T.untyped) }
  def test(x); end

  sig { params(x: T.untyped, y: T.untyped).returns(T.untyped) }
  def add(x, y); end
end
