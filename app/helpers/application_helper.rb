module ApplicationHelper

  def startj
    raw "$(document).bind('pageinit', function () {"
  end
  
  def endj
    raw "});"
  end

  def back_button(url)
    unless flash[:suppress_back_button]
      raw "<a href='#{url.present? ? url : '#'}' data-add-back-btn='true' data-direction='reverse'>#{image_tag 'backbutton.png', :width => 38}</a>"
    end
  end

    def user_image(user, size, params = Hash.new)
        return '' unless user
        params.merge!(:class => 'profile_image', :alt => ':)', :title => ':)')
        image_tag user.photo_url(size), params
    end

    #  :styles => { :large => "800x800>", 
    #               :medium => "300x300>", 
    #               :small => "75x75#", 
    #               :tiny => "30x30#" },
    def budgee_user_image(user_budge, size, params = Hash.new)
        return '' unless user_budge
        params.merge!(:class => 'profile_image', :alt => ':)', :title => ':)')
        if user_budge.user
          return raw(image_tag user_budge.user.photo_url(size), params)          
        elsif user_budge.post_to_twitter?
          return raw("<img src='http://api.twitter.com/1/users/profile_image/#{user_budge.remote_user_id}' width='30' height='30' />")
        elsif user_budge.post_to_facebook?
          return raw("<img src='http://graph.facebook.com/#{user_budge.remote_user_id}/picture' width='30' height='30' />")      
        end
    end
    def budgee_user_link(user_budge)
      link = ''
      if user_budge.user
        link = url_for :controller => :profile, :action => :id, :id => user_budge.user_id
      elsif user_budge.post_to_facebook?
        link = "http://facebook.com/profile.php?id=#{user_budge.remote_user_id}"
      elsif user_budge.post_to_twitter?
        link = "http://m.twitter.com/#{user_budge.remote_user_id}"      
      end
      return link
    end

    def jquery_mobile_start(include_script = true)
        if include_script == true
            raw "<script type=\"text/javascript\" language=\"javascript\">\n"+
            "$(document).ready(function() {\n"+
            "$(document).bind(\"deviceready\", function(){\n".html_safe 
        else
            raw "$(document).ready(function() {\n"+
            "$(document).bind(\"deviceready\", function(){\n".html_safe 
        end
    end
    
    def jquery_mobile_end(include_script = true)
        if include_script == true
            raw "});\n});\n</script>".html_safe
        else
            raw "});\n});".html_safe        
        end
    end

    def jquery_start
        raw "$(document).ready(function() {\n".html_safe
    end
    
    def jquery_end
        raw "});".html_safe
    end

    def pretty_date(date)
        "#{date.strftime('%A %B,')} #{date.day.to_i.ordinalize}"
    end
    def pretty_date_minus_month(date)
        "#{date.strftime('%A')} the #{date.day.to_i.ordinalize}"
    end

end