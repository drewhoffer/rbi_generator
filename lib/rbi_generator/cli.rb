require "thor"
require_relative "generator"
module RbiGenerator
  # Generate will take a filepath and then we generate the rbi file beside it
  class CLI < Thor
    desc "generate FILEPATH", "Generate an RBI file for the given Ruby file"
    def generate(file_path)
      unless File.exist?(file_path)
        puts "File not found: #{file_path}"
        exit(1)
      end
      Generator.new(file_path).generate
    end
  end
end
