require 'noridoc/java_parser'

module NoriDoc
  class Doclet
    def self.start(root_doc)
      class_map = NoriDoc::JavaParser.new(root_doc).parse
      class_map.each do |key, jclass|
        superclass = jclass.superclass
        superclass_str = superclass ? " < #{superclass.name}" : ""
        puts "Class: #{jclass.name}#{superclass_str}"
        jclass.ruby_methods.each do |rmethod|
          puts "  #{rmethod.java_name} (#{rmethod.ruby_names.join(", ")})"
        end
        puts
      end
      true
    end
  end
end
