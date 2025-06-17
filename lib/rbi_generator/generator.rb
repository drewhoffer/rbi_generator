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
      result = Prism.parse(content)
      class_node = find_first_class_node(result.value)
      return unless class_node

      class_name = class_node.name
      method_names = get_all_method_names(class_node)

      write_rbi_to_file(class_name, method_names)
      puts "Generated RBI file: #{@rbi_path}"
    end

    private

    def write_rbi_to_file(class_name, methods)
      rbi = +"class #{class_name}\n"

      methods.each do |method|
        name = method[:name]
        params = method[:params]
        sig = if params.empty?
                "  sig { void }"
              else
                typed_params = params.map { |p| "#{p}: T.untyped" }.join(", ")
                "  sig { params(#{typed_params}).returns(T.untyped) }"
              end
        rbi << "#{sig}\n"
        def_line = "  def #{name}"
        def_line << "(#{params.join(", ")})" unless params.empty?
        def_line << "; end\n\n"
        rbi << def_line
      end

      rbi << "end\n"
      File.write(@rbi_path, rbi)
    end

    # Recursively find the first ClassNode in the AST
    def find_first_class_node(node)
      return node if node.is_a?(Prism::ClassNode)
      return nil unless node.respond_to?(:child_nodes)

      node.child_nodes.each do |child|
        found = find_first_class_node(child)
        return found if found
      end
    end

    # Goes through the class and grab every child node (they will be defined as defNode)
    def get_all_method_names(class_node)
      class_node.body.child_nodes
                .select { |child| child.is_a?(Prism::DefNode) }
                .map do |method_node|
        {
          name: method_node.name,
          params: get_method_params(method_node)
        }
      end
    end

    def get_method_params(method_node)
      params_node = method_node.parameters
      return [] unless params_node

      all_params = []

      all_params += params_node.requireds.map { |p| p.name }
      all_params += params_node.optionals.map { |p| p.name }
      all_params << params_node.rest.name if params_node.rest
      all_params += params_node.posts.map { |p| p.name }
      all_params += params_node.keywords.map { |p| p.name }
      all_params << params_node.keyword_rest.name if params_node.keyword_rest
      all_params << params_node.block.name if params_node.block
      all_params.compact
    end
  end
end
