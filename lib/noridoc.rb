require 'noridoc/java_parser'

module NoriDoc
  class Doclet
    def self.start(root_doc)
      class_map = NoriDoc::JavaParser.new(root_doc).parse
      class_map.each do |key, value|
        puts value
      end
      true
    end
  end
end
