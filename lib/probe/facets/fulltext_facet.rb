class Probe::Facets
  class FulltextFacet < Probe::Facets::Facet
    include Probe::Search::Query

    attr_accessor :highlights,
                  :query_options

    def initialize(name, field, options)
      super name, field, options

      @highlights   = options[:highlights] ? options[:highlights] : @field
      @use_wildcard = options[:use_wildcard]
    end

    def terms=(value)
      @terms = value
    end

    def build_query
      build_query_from(@field, @terms, query_options)
    end

    def build_filter
      [build_query_filter_from(@field, @terms, query_options)]
    end

    def parse_terms(value)
      value.respond_to?(:join) ? value.join(' ') : value.to_s
    end

    private

    def query_options
      @query_options ||= { operator: :or, analyze_wildcard: true, use_wildcard: @use_wildcard }
    end
  end
end
