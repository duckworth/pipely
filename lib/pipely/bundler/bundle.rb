require 'fileutils'

module Pipely
  module Bundler

    #
    # Provides access to a bundle's list of gems
    #
    class Bundle

      attr_reader :spec_set

      SOURCE_TYPES = %w[Bundler::Source::Git Bundler::Source::Path]

      def self.build(vendor_dir,
                     groups=[:default],
                     definition=::Bundler.definition)
        new(
          vendor_dir,
          definition.specs_for(groups),
          definition.instance_variable_get(:@locked_sources)
        )
      end

      def initialize(vendor_dir, spec_set, locked_sources)
        @spec_set = spec_set
        @locked_sources = locked_sources
        @vendor_dir = vendor_dir
        unless Dir.exists? @vendor_dir
          FileUtils.mkdir_p(@vendor_dir)
        end

      end

      def gem_files(gem_packager=GemPackager.new(@vendor_dir))
        gem_files = {}

        @spec_set.to_a.each do |spec|
          gem_files.merge!(gem_file(spec, gem_packager))
        end

        gem_files
      end

    private

      def gem_file(spec, gem_packager)
        if source = locked_sources_by_name[spec.name]
          gem_packager.build_from_source(source.name, source.path)
        else
          gem_packager.package(spec)
        end
      end

      def locked_sources_by_name
        return @locked_sources_by_name if @locked_sources_by_name

        @locked_sources_by_name = {}

        @locked_sources.each do |source|
          # Only include git or path sources.
          if SOURCE_TYPES.include?(source.class.name)
            @locked_sources_by_name[source.name] = source
          end
        end

        locked_sources_by_name
      end

    end

  end
end
