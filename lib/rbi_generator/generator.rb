# frozen_string_literal: true

require "ripper"
require "prism"
require "pp"

module RbiGenerator
  class Generator
    def initialize(file_path)
      @file_path = file_path
      @rbi_path = @file_path.sub(/\.rb$/, ".rbi")
    end

    def generate
      content = File.read(@file_path)
      ast = Ripper.sexp(content)
      pp ast
      class_name = extract_class_name(ast)
      method_names = extract_method_names(ast)
      puts "Class Name: #{class_name}"
      puts "Method Names: #{method_names.join(", ")}"
      # puts "Method Names: #{method_names.join(", ")}"
      # puts Ripper.sexp(content)
    end

    # Takes the syntax tree and extracts the class name
    def extract_class_name(ast)
      class_node = ast[1].find { |node| node[0] == :class }
      class_node[1][1] if class_node
    end

    def extract_method_names(ast)
      class_node = ast[1].find { |node| node[0] == :class }
      body = class_node[3] # :bodystmt
      return [] unless body && body[0].is_a?(Array)

      method_defs = body[0].select { |node| node[0] == :def }
      method_defs.map { |def_node| def_node[1][1] } # => ["hello", "goodbye"]
    end
  end
end
