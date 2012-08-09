module DashHelper
  #take a DateTime object and return a simple string 
  def basic_timestamp(t)
    t.nil? ? '' : t.strftime('%Y-%m-%d %H:%M') 
  end
  def basic_datestamp(t)
    t.nil? ? '' : t.strftime('%Y-%m-%d') 
  end
  
  def link_to_user(user)
    if not user.nil?
      link_to "@#{user.twitter_username}","/dash/user/#{user.id}"
    else
      '?'
    end
  end
  
  #collapse an element on the page onclick
  def link_to_collapse(text,target)
    link_to raw("#{text} &#9660;"),'javascript:void(0)', {'data-toggle'=>"collapse", 'data-target'=>target}
  end
  
  def get_percentage(num,denom=100)
    if denom==0
      0
    else
      number_to_percentage((100.0*(num*1.0)/(denom*1.0)), :precision =>0)
    end
  end
  
  def column_headers(*headers)
    content_tag :tr do
      headers.reduce('') { |c, h| c << content_tag(:th, h) }.html_safe
    end
  end
  def display_grid(objects, options={})
    options = {
      :table_class        => 'display_grid',
      :table_id           => "display_grid_#{objects.first.class.to_s.underscore.pluralize}",
      :heading_class      => 'display_grid_heading',
      :heading_id         => "display_grid_heading_#{objects.first.class.to_s.underscore.pluralize}",
      :th_class           => 'display_grid_th',
      :tr_class           => 'display_grid_tr',
      :td_class           => 'display_grid_td',   
      :even_odd           => true,
      :format_date        => nil, #nil | lambda{|datetime|}
      :numeric_td_class   => 'numeric',
      :date_td_class      => 'date',
      :string_td_class    => 'string',

      :show_action        => nil, # lambda{|object| link_to '', my_path(object)}
      :edit_action        => nil, # lambda{|object|} 
      :destroy_action     => nil, # lambda{|object|}      

    }.merge(options)

    # if row_layout are provided use the names in the row_layout, otherwise find all the to_s attributes and select the keys
    columns = options[:row_layout] ? options[:row_layout] : 
      objects.first.attributes.select{|k,v| v.respond_to?(:to_s)}.collect{|a| a[0]}

    show_action_links = options[:show_action] || options[:edit_action] || options[:destroy_action]

    capture_haml do       
      haml_tag :table, {:id => options[:table_id], :class => options[:table_class]} do

        # Column headings
        haml_tag :tr, { :id => options[:heading_id], :class => [options[:heading_class], options[:tr_class]].join(' ') } do
          columns.each do |col|
            haml_tag :th, { :class => options[:td_class]} do
              haml_concat col.to_s.capitalize.humanize
            end
          end

          haml_tag :th, { :class => options[:td_class]} do
            haml_concat 'Actions' 
          end if show_action_links
        end

        objects.each_with_index do |obj,idx|
          tr_classes = [ options[:tr_class] ]
          tr_classes << ((idx + 1).odd? ? 'odd' : 'even') if options[:even_odd]

          haml_tag :tr, { :id => "#{obj.class.to_s.underscore}_#{obj.id}", :class => tr_classes.join(' ')} do
            columns.each do |col|
              td_classes  = [options[:td_class], col]
              td_value    = obj.send(col)

              case td_value.class.to_s
              when "String"
                td_classes << options[:string_td_class]
              when "Numeric"
                td_classes << options[:numeric_td_class]
              when "Time", "Date", "DateTime","ActiveSupport::TimeWithZone"
                td_value = options[:format_date].call(td_value) if options[:format_date]
                td_classes << options[:date_td_class]
              end

              haml_tag :td, { :class => td_classes.join(' ')} do
                haml_concat td_value
              end
            end

            if show_action_links
              haml_tag :td, { :class => "#{options[:td_class]} actions" } do
                [:show_action, :edit_action, :destroy_action].each do |obj_action|        
                  haml_concat options[obj_action].call(obj) if options[obj_action]
                end
              end
            end

          end                    
        end #end row capture
      end #end rows capture
    end #end table capture
  end #end def display_grid
end