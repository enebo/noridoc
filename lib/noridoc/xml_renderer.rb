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
      io.puts '<?xml version="1.0" encoding="UTF-8"?>'
      io.puts

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

    # TODO: This version is so wrong, but I am keeping it for now
    def param_string(rmethod)
      args = []
      rmethod.java_methods.each do |jmethod|
        jmethod.parameters.each_with_index do |parm, i|
          args[i] ||= {}
          args[i][parm.name] = true
        end
      end
      parm_list = []
      args.each do |arg|
        if arg.keys.size > 1
          parm_list << "{" + arg.keys.join(",") + "}"
        else
          parm_list << arg.keys[0]
        end
      end
      parm_string = parm_list.join(", ")
    end

    def render_detailed_method(io, indent, rmethod)
      param_string = param_string(rmethod)
      tag(io, :method_detail, indent, :name => rmethod.java_name, :param_string => param_string) do |indent|
        rmethod.ruby_names.each do |rname|
          tag(io, :ruby_alias, indent, :name => rname)
        end
        java_methods = rmethod.java_methods
        if java_methods.length == 1
          render_detailed_method_tags(io, indent, java_methods[0])
        else
          tag(io, :java_overloads, indent) do |indent2|
            rmethod.java_methods.each do |jmethod|
              tag(io, :java_overload, indent2, :name => jmethod.name, :signature => jmethod.signature) do |indent3|
                render_detailed_method_tags(io, indent3, jmethod)
              end
            end
          end
        end

      end
    end

    def render_detailed_method_tags(io, indent, jmethod)
      jmethod.param_docs.each do |param|
        if param.text =~ /(\w+)\s+(.*)/
          name, text = $1, $2
          tag(io, :param, indent, :name => name) do |indent|
            io.puts indent + text
          end
        end
      end
      if jmethod.return_doc
        tag(io, :returns, indent) do |indent|
          io.puts indent + jmethod.return_doc
        end
      end
    end

    def render_method_details(io, indent)
      tag(io, :method_details, indent) do |indent|
        @jclass.ruby_methods.sort { |a, b| a.java_name <=> b.java_name}.each do |rmethod|
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
