require 'noridoc/xml/helpers'

module NoriDoc
  module XML
    class PackageRenderer
      include XMLHelpers

      def initialize(root)
        @root = root
      end

      def render(package, io=$stdout)
        tag(io, :packages) do |indent|
          render_package(io, indent, package)
        end
      end

      def render_package(io, indent, package)
        tag(io, :package, indent, :name => package.name) do |indent|
          render_containing_packages(io, indent, package)
          render_package_class_list(io, indent, package)
        end
      end

      def render_containing_packages(io, indent, package)
        tag(io, :containing_packages, indent) do |indent|
          package.containing_packages(@root).each do |sub|
            split = sub.name.split('.')
            short_name = split[-1]
            path = split.join("/")
            tag(io, :containing_package, indent, :name => short_name, :package_path => path)
          end
        end
      end

      def render_package_class_list(io, indent, package)
        tag(io, :class_list, indent) do |indent2|
          package.all_classes.each do |cls|
            package_path = package.name.gsub(".", "/")
            tag(io, :class, indent2, :name => cls.name, :package_path => package_path)
          end
        end
      end
    end
  end
end
