require "minitest/autorun"
require_relative "../lib/rbi_generator/generator"

class RbiGeneratorTest < Minitest::Test
  def setup
    @test_file = "test/test_class.rb"
    File.write(@test_file, <<~RUBY)
      class TestClass
        def hello; end
        def test(x); end
        def add(x, y); end
      end
    RUBY
    @generator = RbiGenerator::Generator.new(@test_file)
  end

  def teardown
    File.delete(@test_file) if File.exist?(@test_file)
    rbi_file = @test_file.sub(/\.rb$/, ".rbi")
    File.delete(rbi_file) if File.exist?(rbi_file)
  end

  def test_generate_creates_rbi_file
    @generator.generate
    rbi_path = @test_file.sub(/\.rb$/, ".rbi")
    assert File.exist?(rbi_path), "RBI file should be created"
    content = File.read(rbi_path)
    assert_includes content, "class TestClass"
    assert_includes content, "def hello; end"
    assert_includes content, "def test(x); end"
    assert_includes content, "def add(x, y); end"
  end
end
