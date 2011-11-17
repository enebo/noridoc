require 'noridoc/java_parser'
require 'noridoc/xml_renderer'

module NoriDoc
  class Doclet
    def self.start(root_doc)
      NoriDoc::JavaParser.new(root_doc).parse.each do |name, jclass|
        NoriDoc::XMLClassRenderer.new(jclass).render
      end
      true
    end
  end
end
