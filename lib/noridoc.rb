require 'java'
require 'fileutils'
require 'noridoc/java_parser'
require 'noridoc/xml/class_renderer'
require 'noridoc/xml/all_packages_renderer'
require 'noridoc/xml/package_renderer'

import javax.xml.transform.TransformerFactory

module NoriDoc
  STYLESHEET_DIR = File.join(File.dirname(__FILE__), 'noridoc', 'stylesheets')
  HTML_CLASS_STYLESHEET = File.join(STYLESHEET_DIR, "class_renderer.xslt")
  PACKAGE_STYLESHEET = File.join(STYLESHEET_DIR, "package_renderer.xslt")

  class Doclet
    def self.start(root_doc)
      transform_all_packages root_doc
      transform_individual_packages root_doc

      NoriDoc::JavaParser.new(root_doc).parse.each do |name, jclass|
        xml_path = package_to_pathname(jclass, ".xml")
        File.open(xml_path, "w") do |io|
          NoriDoc::XML::ClassRenderer.new(jclass).render(io)
        end
        html_path = package_to_pathname(jclass, ".html")
        xslt_transform(xml_path, HTML_CLASS_STYLESHEET, html_path)
      end
      true
    end

    def self.transform_all_packages(root_doc)
      xml_path = File.join("docs", "all_packages.xml")
      File.open(xml_path, "w") do |io|
        NoriDoc::XML::AllPackagesRenderer.new(root_doc).render(io)
      end
      html_path = File.join("docs", "all_packages.html")
      xslt_transform(xml_path, PACKAGE_STYLESHEET, html_path)
    end

    def self.transform_individual_packages(root_doc)
      renderer = NoriDoc::XML::PackageRenderer.new(root_doc)
      root_doc.specified_packages.each do |package|
        xml_path = File.join("docs", package.to_path + ".xml")
        File.open(xml_path, "w") { |io| renderer.render(package, io) }
        html_path = File.join("docs", package.to_path + ".html")
        xslt_transform(xml_path, PACKAGE_STYLESHEET, html_path)
      end
    end

    def self.xslt_transform(xml, style_sheet, file)
      document = javax.xml.transform.stream.StreamSource.new xml
      stylesheet = javax.xml.transform.stream.StreamSource.new style_sheet
      output = java.io.FileOutputStream.new(file)
      result = javax.xml.transform.stream.StreamResult.new output

      begin
        transformer = TransformerFactory.newInstance.newTransformer(stylesheet)
        transformer.transform(document, result)
      rescue javax.xml.transform.TransformerException => e
        puts "TRANSFORMER ERROR in #{xml} with #{style_sheet}"
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
