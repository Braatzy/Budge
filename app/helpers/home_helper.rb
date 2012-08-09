module HomeHelper
  def button(text,link={},html_options={})
    options={:class=>'button','data-role'=>'button'}.merge(html_options)
    if options[:class]=='button_important'
      options['data-theme']='e'
    end
    if options[:class]=='button_half_right'
      content_tag(:div, :class=>'.ui-block-a') do
        link_to text, link, options
      end
    elsif options[:class]=='button_half_left'
      content_tag(:div, :class=>'.ui-block-a') do
        link_to text, link, options
      end  
    else
      link_to text, link, options
    end
  end
end
