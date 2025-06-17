require "thor"

module RbiGenerator
  # Generate will take a filepath and then we generate the rbi file beside it
  class CLI < Thor
    desc "generate FILEPATH", "Generate an RBI file for the given Ruby file"
    def generate(file_path)
      if File.exist?(file_path)
        # Here you would implement the logic to generate the RBI file
        # For now, we will just print a message
        puts "Generating RBI for #{file_path}..."
        # Example: File.write("#{file_path}.rbi", "Generated RBI content")
      else
        puts "File not found: #{file_path}"
      end
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
    end
  end
end
