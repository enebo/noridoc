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
        up_path = calculate_up_path(package.name)
        tag(io, :package, indent, :name => package.name) do |indent|
          render_containing_packages(io, indent, package, up_path)
          render_package_class_list(io, indent, package, up_path)
        end
      end

      def render_containing_packages(io, indent, package, up_path)
        tag(io, :containing_packages, indent) do |indent|
          package.containing_packages(@root).each do |sub|
            split = sub.name.split('.')
            short_name = split[-1]
            path = split.join("/")
            tag(io, :containing_package, indent, :name => short_name, :package_path => up_path + path)
          end
        end
      end

      # Location relative to current directory we should move up to
      # make package_path values work.  Note, on all_packages don't
      # need an up_path so it overrides and returns ''
      def calculate_up_path(name)
          up_path = ''
          (name.split('.').length - 1).times do 
            up_path += '../'
          end
          up_path
      end

      def render_package_class_list(io, indent, package, up_path)
        tag(io, :class_list, indent) do |indent2|
          package.all_classes.sort {|a, b| a.name <=> b.name}.each do |cls|
            package_path = up_path + package.name.gsub(".", "/")
            tag(io, :class, indent2, :name => cls.name, :package_path => package_path)
          end
        end
      end
    end
  end
end
