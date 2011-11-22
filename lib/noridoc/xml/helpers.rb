module NoriDoc
  module XML
    module XMLHelpers
      def prologue(io)
        io.puts '<?xml version="1.0" encoding="UTF-8"?>'
        io.puts
      end

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

      # FIXME: This should become something much richer since generics should
      # contain links to other types etc...
      def sanitize_type(str)
        return "" unless str
        str.gsub!('<', '&lt;')
        str.gsub!('>', '&gt;')
        str
      end

      # FIXME: Really really hacky and obviously only works for simple known stuff
      def sanitize_doc_string(str)
        return "" unless str
        str.gsub!(/&([^a-zA-Z])/, '&amp;_1')
        str.gsub!(/<([^\/]+)>/, '_1/')
        str
      end

      # Location relative to current directory we should move up to
      # make package_path values work.  Note, on all_packages don't
      # need an up_path so they should override and return ''
      def calculate_up_path(name)
          up_path = ''
          (name.split('.').length - 1).times do 
            up_path += '../'
          end
          up_path
      end
    end
  end
end
