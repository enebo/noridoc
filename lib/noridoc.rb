require 'noridoc/java_parser'

module NoriDoc
  class Doclet
    def self.start(root_doc)
      NoriDoc::JavaParser.new(root_doc)
      true
    end
  end
end
