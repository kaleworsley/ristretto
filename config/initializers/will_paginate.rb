
module WillPaginate  
  class BootstrapLinkRenderer < LinkRenderer   
    def to_html
      links = @options[:page_links] ? windowed_links : []
      # previous/next buttons
      links.unshift page_link_or_span(@collection.previous_page, 'disabled prev', "&larr; Previous")
      links.push page_link_or_span(@collection.next_page, 'disabled next', "Next &rarr;")
      
      html = links.join(@options[:separator])
      html = html.html_safe if html.respond_to? :html_safe
      
      @template.content_tag(:div, @template.content_tag(:ul, html), html_attributes)
    end

    def gap_marker
      @gap_marker = begin
        %(<li class="disabled"><a href="#">&hellip;</a></span>)
      end
    end    
    
    protected       
      def page_link_or_span(page, span_class, text = nil)
        text ||= page.to_s
        text = text.html_safe if text.respond_to? :html_safe
        
        if page and page != current_page
          classnames = span_class && span_class.index(' ') && span_class.split(' ', 2).last
          page_link page, text, :rel => rel_value(page), :class => classnames
        else
          page_link page, text, :class => span_class
        end
      end 
      
      def page_link(page, text, attributes = {})
        @template.content_tag(:li, @template.link_to(text, url_for(page)), attributes)
      end
      
      def windowed_links
        prev = nil

        visible_page_numbers.inject [] do |links, n|
          links << gap_marker if prev and n > prev + 1
          links << page_link_or_span(n, 'active')
          prev = n
          links
        end
      end      
  end
end

WillPaginate::ViewHelpers.pagination_options[:renderer] = 'WillPaginate::BootstrapLinkRenderer'
