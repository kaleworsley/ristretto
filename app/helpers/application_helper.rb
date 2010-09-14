# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def display_flashes
    output = '';
    if flash[:notice].present?
      output += content_tag 'div', flash[:notice], :class => "flash round-5 message notice"
    end

    if flash[:warning].present?
      output += content_tag 'div', flash[:warning], :class => "flash round-5 message warning"
    end

    if flash[:error].present?
      output += content_tag 'div', flash[:error], :class => "flash round-5 message error"
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

  def page_help(help_text)
    content_for(:page_help) { help_text }
  end

  def javascript(*files)
    content_for(:head) { javascript_include_tag files }
  end

  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag files }
  end

  def post_info(object, prefix = 'Created by', gravatar = true, tag = 'div')
    output = '<' + tag + ' class="post-info">'
    if (gravatar)
      output += link_to(gravatar(object.user, 24), object.user, :class => 'gravatar')
    end
    output +=  prefix + ' '
    output += link_to(object.user.full_name, object.user)
    output += ' on '
    output += object.created_at.strftime("%d/%m/%Y")
    output += ' at '
    output += object.created_at.strftime("%I:%M %p")
    output += '</' + tag + '>'

    return output
  end

  def crumb(text, target)
    content_tag(:li, link_to(truncate(h(text), { :length => 30 }), target, {:title => text}))
  end

  def tab(text, target)
    content_tag(:li, link_to(h(text), target, {:title => text}))
  end

  # Creates an <li> tag with class="active" if the current controller name is
  # controller_name
  def nav_li(text, target, controller_name = nil, tag_opts = {}, &block)

    controller_name ||= text.downcase

    if controller.controller_name == controller_name
      if tag_opts[:class].blank?
        tag_opts[:class] = 'active'
      else
        tag_opts[:class] += ' active'
      end
    end

    content = '<span>' + link_to(text, target) + '</span>'

    if block_given?
      content += '<ul>'
      content += capture(&block)
      content += '</ul>'
    end
    out = content_tag(:li, content, tag_opts)
    if block_called_from_erb?(block)
      concat(out)
    else
      out
    end
  end

  def notification_button_toggle(object)
    content_tag :div, :class => 'notifications-toggle' do
      if current_user.ignore_mail_from?(object)
        button_to("Enable notifications", { :action => 'enable_mail', :id => object.id }, { :method => :put, :class => 'notifications-toggle', :title => "Enable notification for this #{object.class.to_s}" })
      else
        button_to("Disable notification", { :action => 'disable_mail', :id => object.id }, { :method => :put, :class => 'notifications-toggle', :title => "Disable notification for this #{object.class.to_s}" })
      end
    end
  end

  def action_link(object, action, text = nil, label = false)
    text ||= "#{action} #{object.class}".titlecase
    link = image_tag("#{action}.png", :alt => "#{action} #{object.class}".titlecase, :title => text, :class => action)
    link += ' ' + text if label
    link_to link, {
    :controller => object.class.to_s.tableize,
    :action => action,
    :id => object,
    },
    :class => action
  end

  def show_link(object, label = false)
    action_link(object, 'show', nil, label) if can?(:read, object)
  end

  def edit_link(object, label = false)
    action_link(object, 'edit', nil, label) if can?(:update, object)
  end

  def delete_link(object, label = false)
    action_link(object, 'delete', nil, label) if can?(:destroy, object)
  end

  def markdown(text)
    Markdown.new(text, {:escape_html => true}).to_html
  end

end
