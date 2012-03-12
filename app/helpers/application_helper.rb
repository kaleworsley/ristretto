# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def display_flashes
    close = '<a class="close" href="#">&times;</a>'
    output = '';
    if flash[:notice].present?
      output += content_tag 'div', close+flash[:notice], :class => "alert-message fade in success", 'data-alert' => 'alert'
    end

    if flash[:warning].present?
      output += content_tag 'div', close+flash[:warning], :class => "alert-message fade in warning", 'data-alert' => 'alert'
    end

    if flash[:error].present?
      output += content_tag 'div', close+flash[:error], :class => "alert-message fade in error", 'data-alert' => 'alert'
    end

    unless output.blank?
      return output
    else
      return
    end
  end

  def title(page_title)
    content_for(:title) { page_title }
    content_tag 'h2', :class => 'title' do
      h page_title
    end
  end

  def body_classes
    classes = "#{controller.controller_name} #{controller.controller_name}-#{controller.action_name}"
    classes += " " + @body_classes.join(' ') unless @body_classes.nil?
    return classes
  end

  def javascript(*files)
    content_for(:head) { javascript_include_tag files }
  end

  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag files }
  end

  def crumb(text, target)
    content_tag(:li, '<span class="divider">/</span>' + link_to(truncate(h(text), { :length => 30 }), target, {:title => strip_tags(text)}))
  end

  def tab(text, target, active = false, opts = {}, &block)
    li_opts = {:class => ''}
    ul_opts = {:class => 'dropdown-menu'}
    a_opts = {:class => '', :title => strip_tags(text)}

    if block_given?
      a_opts = {:class => 'dropdown-toggle', 'data-toggle' => 'dropdown', :title => strip_tags(text)}
    end
    a_opts.merge!(opts[:a]) if opts[:a].present?
    
    ul_opts.merge!(opts[:ul]) if opts[:ul].present?    

    if block_given? 
      li_opts = {:class => 'dropdown'}
    end
    
 	  if active 
	    li_opts[:class] += ' active'
	  end

    li_opts.merge!(opts[:li]) if opts[:li].present?

    content = link_to(text, target, a_opts)

    if block_given?
      subcontent = capture(&block)
      if subcontent.present?
        content += content_tag(:ul, subcontent, ul_opts)
      end
    end
    out = content_tag(:li, content, li_opts)
    if block_called_from_erb?(block)
      concat(out)
    else
      out
    end
  end

  # Creates an <li> tag with class="active" if the current controller name is
  # controller_name
  def nav_li(text, target, controller_name = nil, opts = {}, &block)

    controller_name ||= text.downcase

    if block_given?    
      a_opts = {:class => 'dropdown-toggle'}
    else
      a_opts = {}
    end
    a_opts.merge!(opts[:a]) if opts[:a].present?
    
    ul_opts = {:class => 'dropdown-menu'}
    ul_opts.merge!(opts[:ul]) if opts[:ul].present?    

    if block_given? 
      li_opts = {:class => 'dropdown', 'data-dropdown' => 'dropdown'}
    else
      li_opts = {}
    end

    if controller.controller_name == controller_name
      if li_opts[:class].present?
        li_opts[:class] += ' active'
      else
        li_opts[:class] = 'active'
      end
    end


    li_opts.merge!(opts[:li]) if opts[:li].present?    

     
    content = link_to(text, target, a_opts)

    if block_given?
    
    
      subcontent = capture(&block)
      if subcontent.present?
        content += content_tag(:ul, subcontent, ul_opts)
      end
    end
    out = content_tag(:li, content, li_opts)
    if block_called_from_erb?(block)
      concat(out)
    else
      out
    end
  end

  def notification_button_toggle(object)
    content_tag :div, :class => 'notifications-toggle' do
      if current_user.ignore_mail_from?(object)
        button_to("Enable notifications", { :action => 'enable_mail', :id => object.id }, { :method => :put, :class => 'notifications-toggle btn icon mail', :title => "Enable notification for this #{object.class.to_s}" })
      else
        button_to("Disable notification", { :action => 'disable_mail', :id => object.id }, { :method => :put, :class => 'notifications-toggle btn icon mail', :title => "Disable notification for this #{object.class.to_s}" })
      end
    end
  end

  def action_link(object, action, text = nil, label = false)
    text ||= "#{action} #{object.class}".titlecase
    #link = image_tag("#{action}.png", :alt => "#{action} #{object.class}".titlecase, :title => text, :class => action)
    #link += ' ' + text if label
    if label
      link = label
    else
      link = action
    end
    link_to link, {
    :controller => object.class.to_s.tableize,
    :action => action,
    :id => object,
    },
    :class => action + ' btn icon'
  end

  def show_link(object, label = false)
    action_link(object, 'show', nil, label)
  end

  def edit_link(object, label = false)
    action_link(object, 'edit', nil, label)
  end

  def delete_link(object, label = false)
    action_link(object, 'delete', nil, label)
  end

  def markdown(text)
    Markdown.new(text, {:escape_html => true}).to_html
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, h("add_fields(this, '#{association}', '#{escape_javascript(fields)}')"), :class => 'btn add icon')
  end

  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end

  def count_label(count)
    if count && count > 0
      '<span class="label notice">' + count.to_s + '</span>'
    else
      ""
    end
  end
end
