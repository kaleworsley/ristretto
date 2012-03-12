class BasePresenter
  def initialize(object, template)
    @object = object
    @template = template
  end

  def item(label, content = nil, options = {}, &block)
    out = content_tag :strong, label.to_s.humanize + ': '

    if block_given?
      out += capture(&block).to_s
    elsif content.is_a? Symbol
      out += self.send(content).to_s
    else
      out += content
    end
    
    out = content_tag :div, out, options

    if block_called_from_erb?(block)
      concat(out)
    else
      out
    end
  end

private

  def self.presents(name)
    define_method(name) do
      @object
    end
  end

  def h
    @template
  end
 
  def method_missing(*args, &block)
    @template.send(*args, &block)
  end
end

