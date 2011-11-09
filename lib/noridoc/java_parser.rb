module NoriDoc
  class JavaParser
    def initialize(root)
      root.classes.each { |cls| parse_class(cls) }
    end

    def parse_class(cls)
      puts "TYPENAME: #{cls.typeName} #{cls.containing_package.name}"
    end
  end
end
