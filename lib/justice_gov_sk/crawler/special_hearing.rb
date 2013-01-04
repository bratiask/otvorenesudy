module JusticeGovSk
  class Crawler
    class SpecialHearing < JusticeGovSk::Crawler::Hearing
      protected
    
      def process(request)
        super do
          @hearing.type = HearingType.special
          
          @hearing.commencement_date = @parser.commencement_date(@document)
          @hearing.selfjudge         = @parser.selfjudge(@document)
          
          chair_judge
          
          defendant
          
          @hearing
        end
      end
      
      def chair_judge
        name = @parser.chair_judge(@document)
        
        unless name.nil?
          judges_similar_to(name) do |similarity, judge|
            judging(judge, similarity, name, true)
          end
        end
      end
      
      def defendant
        name = @parser.defendant(@document)
        
        unless name.nil?
          defendant = defendant_by_hearing_id_and_name_factory.find_or_create(@hearing.id, name)
          
          defendant.hearing = @hearing
          defendant.name    = name
          
          @persistor.persist(defendant) if defendant.id.nil?
        end
      end
    end
  end
end
