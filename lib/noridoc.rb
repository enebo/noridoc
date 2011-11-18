require 'java'
require 'fileutils'
require 'noridoc/java_parser'
require 'noridoc/xml_renderer'

import javax.xml.transform.TransformerFactory

module NoriDoc
  HTML_CLASS_STYLESHEET = "class_renderer.xslt"
  class Doclet
    def self.start(root_doc)
      generate_package_pages(root_doc.specified_packages)

      NoriDoc::JavaParser.new(root_doc).parse.each do |name, jclass|
        xml_path = package_to_pathname(jclass, ".xml")
        File.open(xml_path, "w") do |io|
          NoriDoc::XMLClassRenderer.new(jclass).render(io)
        end
        html_path = package_to_pathname(jclass, ".html")
        xslt_transform(xml_path, HTML_CLASS_STYLESHEET, html_path)
      end
      true
    end

    def self.generate_package_pages(packages)
      packages.each do |package|
        puts package.name
        puts package.all_classes.map { |c| c.name }.sort.join(', ')
      end
      exit 0
    end

    def self.xslt_transform(xml, style_sheet, file)
      document = javax.xml.transform.stream.StreamSource.new xml
      stylesheet = javax.xml.transform.stream.StreamSource.new style_sheet
      output = java.io.FileOutputStream.new(file)
      result = javax.xml.transform.stream.StreamResult.new output

      begin
        transformer = TransformerFactory.newInstance.newTransformer(stylesheet)
        transformer.transform(document, result)
      rescue java.lang.Exception => e
        puts e
      end
    end

    def self.package_to_pathname(jclass, extension)
      list = ['docs']
      list.concat jclass.package.name.split('.')
      directory = File.join(list)
      FileUtils.mkdir_p directory
      File.join directory, jclass.name + extension
    end
  end
end
