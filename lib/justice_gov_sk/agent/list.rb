module JusticeGovSk
  class Agent
    class List < JusticeGovSk::Agent
      def download(request)
        super(request) do |page|
          page = yield page if block_given?

          form, fields = form_and_fields(page, form_name)

          # Set items per page
          if request.per_page
            if per_page_field_name = fields.find { |f| f.match(/\A.+cmbAGVCountOnPage\z/) }
              form.field_with(name: per_page_field_name).value = request.per_page
              postback_fields(form, per_page_field_name, '')

              print "... "

              page  = form.submit
              @sum += page.content.length
            end
          end

          # Set page
          if request.page
            page = set_page(request, page)
          end

          page
        end
      end

      protected

      def set_page(request, page)
        form, fields = form_and_fields(page, form_name)

        if page_field_name = fields.find { |f| f.match(/\A.+cmbAGVPager\z/) }
          form.field_with(name: page_field_name).value = request.page
          postback_fields(form, page_field_name, '')

          print "... "

          page = form.submit
          @sum += page.content.length
        end

        page
      end

      def form_name
        'aspnetForm'
      end

      def form_and_fields(page, form_name)
        form   = page.form_with(name: form_name)
        fields = form.fields.map(&:name)

        return form, fields
      end

      def postback_fields(form, target, argument)
        form.add_field!('__EVENTTARGET', target)
        form.add_field!('__EVENTARGUMENT', argument)
      end
    end
  end
end
