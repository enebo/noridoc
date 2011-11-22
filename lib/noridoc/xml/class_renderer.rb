require 'noridoc/xml/helpers'

module NoriDoc
  module XML
    class ClassRenderer
      include XMLHelpers

      def initialize(jclass)
        @jclass = jclass
      end

      def render(io=$stdout)
        prologue(io)

        attrs = {:name =>@jclass.name,:package =>@jclass.package,:type=>'java'}
        tag(io, :class, "", attrs) do |indent|
          render_all_packages io, indent
          render_superclass io, indent 
          render_method_list io, indent
          render_method_details io, indent
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

      def render_all_packages(io, indent)
        split = @jclass.package.name.split '.'
        # FIXME:
        tag(io, :all_packages, indent, :path => split.map { '..' }.join('/'))
      end

      def render_detailed_method(io, indent, rmethod)
        param_string = param_string(rmethod)
        tag(io, :method_detail, indent, :name => rmethod.java_name, :param_string => param_string) do |indent|
          ruby_names = rmethod.ruby_names
          if !ruby_names.empty?
            tag(io, :ruby_aliases, indent) do |indent_aliases|
              ruby_names.each do |rname|
                tag(io, :ruby_alias, indent_aliases, :name => rname)
              end
            end
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
          if param.text =~ /(\S+)\s+(.*)/
            name, text = sanitize_type($1), sanitize_doc_string($2)
            tag(io, :param, indent, :name => name) do |indent_param|
              io.puts indent_param + text
            end
          end
        end

        if jmethod.return_doc
          tag(io, :returns, indent) do |indent_return|
            io.puts indent_return + sanitize_type(jmethod.return_doc)
          end
        end
      end

      def render_method_details(io, indent)
        tag(io, :method_details, indent) do |indent|
          render_method_details_inner(io, indent, :class_method_details, @jclass.ruby_class_methods)
          render_method_details_inner(io, indent, :instance_method_details, @jclass.ruby_methods)
        end
      end

      def render_method_details_inner(io, indent, tag_name, methods)
        return if methods.empty?
        sorted_list = methods.sort { |a, b| a.java_name <=> b.java_name}
        tag(io, tag_name, indent) do |indent|
          sorted_list.each do |rmethod|
            render_detailed_method(io, indent, rmethod)
          end
        end
      end

      def render_method_list(io, indent)
        tag(io, :method_outline, indent) do |indent|
          render_method_list_inner(io, indent, @jclass.ruby_class_methods)
          render_method_list_inner(io, indent, @jclass.ruby_methods)
        end
      end

      def render_method_list_inner(io, indent, methods)
        mixed_map = {}
        methods.each do |rmethod|
          link_anchor = rmethod.java_name
          mixed_map[rmethod.java_name] = ['java', link_anchor, rmethod.class_method?]
          rmethod.ruby_names.each do |rname|
            mixed_map[rname] = ['ruby', link_anchor, rmethod.class_method?]
          end
        end

        mixed_map.sort.each do |name, (type, anchor, class_method)|
          tag(io, :method_item, indent, :type => type, :anchor => anchor, :name => name, :class_method => class_method)
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
end
