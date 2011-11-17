module NoriDoc
  module XMLHelpers
    def tag(io, name, indent="", attrs={})
      name = name.to_s
      attr_string = prepare_attrs(attrs)
      if block_given?
        io.write "#{indent}<#{name}#{attr_string}>\n"
        yield indent + "  "
        io.write "#{indent}</#{name}>\n"
      else
        io.write "#{indent}<#{name}#{attr_string}/>\n"
      end
    end

    def prepare_attrs(attrs)
      pairs = []
      attrs.each { |key, value| pairs << %Q{#{key.to_s}="#{value}"} }
      return '' if pairs.size == 0
      ' ' + pairs.join(' ')
    end
  end
  class XMLClassRenderer
    include XMLHelpers

    def initialize(jclass)
      @jclass = jclass
    end

    def render(io=$stdout)
      attrs = {:name =>@jclass.name, :package =>@jclass.package, :type=>'java'}
      tag(io, :class, "", attrs) do |indent|
        render_superclass io, indent 
        render_method_list io, indent
        render_method_details io, indent
        
        # superclass = jclass.superclass
        # superclass_str = superclass ? " < #{superclass.name}" : ""
        # puts "Class: #{jclass.name}#{superclass_str}"
        # jclass.ruby_methods.each do |rmethod|
        #   puts "  #{rmethod.java_name} (#{rmethod.ruby_names.join(", ")})"
        #   puts rmethod.javadocs
        # end
        # puts
      end
    end

    def render_detailed_method(io, indent, rmethod)
      tag(io, :method_detail, indent, :name => rmethod.java_name) do |indent|
        rmethod.ruby_names.each do |rname|
          tag(io, :ruby_alias, indent, :name => rname)
        end
      end
    end

    def render_method_details(io, indent)
      tag(io, :method_details, indent) do |indent|
        @jclass.ruby_methods.each do |rmethod|
          render_detailed_method(io, indent, rmethod)
        end
      end
    end

    def render_method_list(io, indent)
      mixed_map = {}
      @jclass.ruby_methods.each do |rmethod|
        link_anchor = rmethod.java_name
        mixed_map[rmethod.java_name] = ['java', link_anchor]
        rmethod.ruby_names.each do |rname|
          mixed_map[rname] = ['ruby', link_anchor]
        end
      end

      tag(io, :method_outline, indent) do |indent|
        mixed_map.sort.each do |name, (type, anchor)|
          tag(io, :method_item, indent, :type => type, :anchor => anchor, :name => name)
        end
      end
    end

    def render_superclass(io, indent)
      if @jclass.superclass
        name = @jclass.superclass.name
        package = @jclass.superclass.package
      else
        name = 'Object'
        package = 'java.lang'
      end
      tag(io, :superclass, indent, :name => name, :package => package)
    end
  end
end
