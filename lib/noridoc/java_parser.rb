require 'noridoc/modifier'

module NoriDoc
  class RMethod
    attr_reader :java_name, :ruby_names

    def initialize(name, jmethods, class_method=false)
      @java_name, @jmethods, @class_method = name, jmethods, class_method
      calculate_ruby_names
    end

    def calculate_ruby_names
      @ruby_names = [] 
      @ruby_names.concat shorthand_names(@jmethods)
      snakecase = snakecase(java_name)
      @ruby_names << snakecase if snakecase != java_name
    end

    # TODO: Probably move these to module
    def snakecase(name)
      name.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase
    end

    def class_method?
      @class_method
    end

    def java_methods
      @jmethods
    end

    def javadocs
      text = ""
      @jmethods.each do |method|
        text << method.name << method.signature << "\n" << method.text
        if method.return_doc
          text << "\nreturns: " << method.return_doc << "\n"
        end
        method.parameters.each do |parm|
            text << "parm: #{parm.name} #{parm.typeName} #{parm.type} #{parm.toString}\n"
        end
      end
      text
    end
    
    # FIXME: Should make sure these methods really qualify based on things like
    # return type, etc..
    def shorthand_names(methods)
      names = []
      if java_name =~ /\Aget(.+)/
        names << snakecase($1[0,1].downcase + $1[1..-1])
      elsif java_name =~ /\Aset(.+)/
        names << snakecase($1[0,1].downcase + $1[1..-1]) + '='
      elsif java_name =~ /\Ais(.+)/
        return unless $1
        short_name = snakecase($1[0,1].downcase + $1[1..-1])
        names << short_name
        names <<  short_name + '?'
      end
      names
    end
    
  end
  
  class JModel
    include NoriDoc::Modifier

    attr_reader :modifiers, :name, :parser

    def initialize(name, modifiers)
      @name, @modifiers =  name, modifiers
    end
  end

  class JConstructor < JModel
    def initialize(constructor)
      super(constructor.name, constructor.modifier_specifier)
    end

    def self.parse(constructor)
      JConstructor.new constructor
    end
  end

  class JField < JModel
    def initialize(field)
      super(field.name, field.modifier_specifier)
    end

    def self.parse(field)
      JField.new field
    end
  end

  # param.name - short name
  # param.typeName - show type name
  # param.type - fqn type name
  class JMethod < JModel
    attr_reader :signature, :text, :tags, :parameters

    def initialize(method)
      super(method.name, method.modifier_specifier)
      @parameters = method.parameters || []
      @signature = method.signature
      @text = method.comment_text
      @tags = method.tags
    end

    def param_docs
      @tags.find_all { |t| t.name == '@param' } || []
    end

    def return_doc
      return_tag = @tags.find { |t| t.name == '@return' }
      return_tag ? return_tag.text : nil
    end

    def self.parse(method)
      JMethod.new method
    end
  end

  # FIXME: Consider adding generics
  class JClass < JModel
    attr_reader :package, :fields, :constructors, :inner_classes, :interfaces
    attr_accessor :superclass
    
    def initialize(cls)
      super(cls.name, cls.modifier_specifier)
      @package = cls.containing_package
      @superclass = nil # JClass
      @constructors = [] # JConstructor...
      @methods = {} # name => [overload1, overload2...]
      @class_methods = {} # name => [overload1, overload2...]
      @fields = [] # JField...
      @inner_classes = [] # JClass...
      @interfaces = [] # JClass...
    end
    
    def add_constructor(constructor)
      @constructors << constructor
    end
    
    def add_method(method)
      map = method.static? ? @class_methods : @methods
      overloads = map[method.name] || []
      overloads << method
      map[method.name] = overloads
    end

    def ruby_methods
      @methods.keys.map { |name| RMethod.new name, @methods[name] }
    end

    def ruby_class_methods
      @class_methods.keys.map { |name| RMethod.new name, @class_methods[name], true }
    end

    def fqn
      "#{package}.#{name}"
    end

    def to_s
      fqn
    end

    # TODO: Need to add superClass and interface linking
    def self.parse(parser, cls)
      JClass.new(cls).tap do |jcls|
        cls.fields.each { |field| jcls.fields << JField.parse(field) }
        cls.constructors.each { |c| jcls.constructors << JConstructor.parse(c) }
        cls.methods.each { |method| jcls.add_method JMethod.parse(method) }
        cls.inner_classes.each { |i| jcls.inner_classes << parser.class_for(i) }
        cls.interfaces.each { |i| jcls.interfaces << parser.class_for(i) }
        jcls.superclass = parser.class_for(cls.superclass) 
      end
    end
  end

  module com::sun::javadoc::PackageDoc
    # Return a list of all packagedocs from this package down.
    # This is typically called for creating hyperlinks for each sub-package.
    def containing_packages(root)
      combined = ''
      self.name.split('.').inject([]) do |list, fragment|
        combined += fragment
        found_package = root.package_named(combined)
        list << found_package if found_package
        combined += '.'
        list
      end
    end

    def to_path
      File.join(name.split('.'))
    end
  end
  
  class JavaParser
    attr_reader :classes, :root

    def initialize(root)
      @root = root
      @classes = {} # FQN => JClass
    end

    def parse
      @root.classes.each { |cls| class_for(cls) }
      @classes
    end

    # FIXME: Are cycles possible? Might need to mark classes table if so
    def class_for(cls)
      return nil unless cls # superclass will return nil when none
      fqn = cls.qualified_type_name
      return classes[fqn] if classes[fqn]
      classes[fqn] = JClass.parse(self, cls)
    end
  end
end
