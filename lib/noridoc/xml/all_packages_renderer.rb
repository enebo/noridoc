require 'noridoc/xml/helpers'
require 'noridoc/xml/package_renderer'

module NoriDoc
  module XML
    class AllPackagesRenderer < PackageRenderer
      include XMLHelpers

      def initialize(root)
        super(root)
      end

      def render(io=$stdout)
        tag(io, :packages) do |indent|
          @root.specified_packages.each do |package|
            render_package(io, indent, package)
          end
        end
      end

      def calculate_up_path(name)
        ''
      end
    end
  end
end
