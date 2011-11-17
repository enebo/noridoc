require 'noridoc/modifier'

module NoriDoc
  class JModel
    include NoriDoc::Modifier

    attr_reader :modifiers, :name

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

  class JMethod < JModel
    def initialize(method)
      super(method.name, method.modifier_specifier)
    end

    def self.parse(method)
      JMethod.new method
    end
  end

  # FIXME: Consider adding generics
  class JClass < JModel
    attr_reader :package, :fields, :constructors, :inner_classes
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
      end
    end
  end
  
  class JavaParser
    attr_reader :classes

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
      fqn = cls.qualified_type_name
      return classes[fqn] if classes[fqn]
      classes[fqn] = JClass.parse(self, cls)
    end
  end
end
