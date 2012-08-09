class StoreController < ApplicationController
  layout 'app'
  before_filter :authenticate_user!, :except => [:index, :pay, :program, :quickbuy]
  
  # Store home page
  # https://beta.getbudged.com/store
  def index
    @programs = Program.where(:featured => true)
    if !current_user or current_user.hasnt_bought_anything_yet?
      @programs_are_free = true
    end
    @programs_are_free = true
  end
  
  # Program detail page
  def program
    @program = Program.find_by_token params[:id]
    raise "No program." unless @program.present?
    
    if params[:invitation_id]
      @invitation = Invitation.find params[:invitation_id]
    end

    if current_user
      @num_active_programs = current_user.active_program_players.size
      @has_program = @program.has_been_purchased_by?(current_user)
    else
      @num_active_programs = 0
    end

    # See if this is their free game
    if !current_user or current_user.hasnt_bought_anything_yet? or @num_active_programs <= User::NUM_ACTIVE_PROGRAMS_AT_ONCE
      @programs_are_free = true
    end
    if current_user
      @has_program = @program.has_been_purchased_by?(current_user)
    end
    
    # See if they have this program
    if current_user
      @has_program = @program.has_been_purchased_by?(current_user)
    end
    
    @first_program_budge = @program.first_budge
    @first_action_template = @first_program_budge.program_action_templates.first
    @program_budge_placement_levels = @program.program_budges.where(:available_during_placement => true).sort_by{|p|p.sort_by}
    
    @facebook_object = {:app_id => OAUTH[Rails.env]['facebook']['consumer_key'],
                        :type => "website",
                        :url => "https://#{SECURE_DOMAIN}#{request.fullpath}",
                        :title => @program.name,
                        :description => @program.description,
                        :image => @program.photo(:medium)}
    
  end
  
  # First program is on us... (don't require cc or credit)
  def quickbuy
    @program_budge = ProgramBudge.find params[:id]
    raise "No budge to buy: #{params[:id]}" unless @program_budge.present?
    @program = @program_budge.program

    if current_user
      @num_active_programs = current_user.valid_program_players.size
    else
      @num_active_programs = 0
    end
    
    if !current_user 
      session[:redirect_after_oauth] = url_for(:controller => :store, :action => :quickbuy, :id => @program_budge.id)
      redirect_to :controller => :users, :action => :sign_up
      return 
      
    elsif current_user.hasnt_bought_anything_yet? or @num_active_programs <= User::NUM_ACTIVE_PROGRAMS_AT_ONCE
      program_player = @program.create_program_player(current_user)

      if program_player.present?
        TrackedAction.add(:redeemed_free_program, current_user)
        flash[:kissmetrics_set] ||= Array.new
        flash[:kissmetrics_set] << {:name => "Billing Amount", :value => 0}
        flash[:kissmetrics_set] << {:name => "Billing Description", :value => "Free game"}
        flash[:kissmetrics_set] << {:name => "Plan Name", :value => @program.name}
        flash[:kissmetrics_record] ||= Array.new
        flash[:kissmetrics_record] << {:name => "Free program redeemed"}

        program_player.update_attributes(:max_level => @program_budge.level)
        player_budge = program_player.start_budge(@program_budge)
        flash[:kissmetrics_record] << {:name => "Started budge"} 

        flash[:message] = "Welcome to #{@program.name}!"
        redirect_to :protocol => 'http://', :host => DOMAIN, :controller => :play, :action => :program, :id => @program.id
      end
    else
      # redirect_to :protocol => 'https://', :host => SECURE_DOMAIN, :controller => :store, :action => :pay, :id => @program.id, :type => 'program', :optional_id => @program_budge.id 
      redirect_to :protocol => 'http://', :host => DOMAIN, :controller => :play, :action => :too_many_programs
    end
  end
  
  # Get Started page: AKA Pay Me!
  # http://www.braintreepayments.com/docs/ruby/reference/countries
  # http://www.braintreepayments.com/docs/ruby/reference/sandbox
  def pay
    payment_details = {:type => nil,
                       :redirect_url => nil,
                       :merchant_account_id => "budge",
                       :amount => nil}
                       
    params[:type] ||= 'none'

    case params[:type]
    when 'none' # Just adding a payment method. NOT paying for anything
      @cancel_url = {:controller => :profile, :action => :settings}
      payment_details.merge!({:type => 'authorize',
                              :redirect_url => "/store/authorization_confirm",
                              :amount => 0.01})

      @kissmetrics[:record] << {:name => "Entered authorization pipeline", 
                                :properties => [{:name => 'Logged In', :value => (current_user ? 'true' : 'false')}]}
                                    
    when 'program' # Buying a program
      @program = Program.find params[:id]
      @item_being_purchased = @program
      @program_budge = ProgramBudge.find params[:optional_id] if params[:optional_id].present?
      @optional_id = @program_budge.id if @program_budge.present?
      @cancel_url = {:controller => :store, :action => :program, :id => @program.token}
      payment_details.merge!({:type => 'program',
                              :redirect_url => "/store/payment_confirm/#{@program.id}/program/#{(@program_budge.present? ? @program_budge.id : nil)}",
                              :amount => @program.price})

      if !current_user 
        @kissmetrics[:record] << {:name => "Entered payment pipeline (not in beta though)", 
                                  :properties => [{:name => 'Purchase Type', :value => params[:type]},
                                                  {:name => 'Name', :value => @program.name},
                                                  {:name => 'Price', :value => @program.price},
                                                  {:name => 'Logged In', :value => (current_user ? 'true' : 'false')}]}
      else
        @kissmetrics[:record] << {:name => "Entered payment pipeline", 
                                  :properties => [{:name => 'Purchase Type', :value => params[:type]},
                                                  {:name => 'Name', :value => @program.name},
                                                  {:name => 'Price', :value => @program.price},
                                                  {:name => 'Logged In', :value => (current_user ? 'true' : 'false')}]}
      end
    when 'program_coach' # Buying a coach subscription
      @program_coach = ProgramCoach.find params[:id]
      @item_being_purchased = @program_coach
      @cancel_url = {:controller => :play, :action => :onboarding, :id => @program_coach.program_id, :anchor => 'coaches'}
      payment_details.merge!({:type => 'program_coach',
                              :redirect_url => "/store/payment_confirm/#{@program_coach.id}/program_coach",
                              :amount => @program_coach.price})

      @kissmetrics[:record] << {:name => "Entered payment pipeline", 
                                :properties => [{:name => 'Purchase Type', :value => params[:type]},
                                                {:name => 'Name', :value => @program_coach.user.twitter_username},
                                                {:name => 'Price', :value => @program_coach.price},
                                                {:name => 'Logged In', :value => (current_user ? 'true' : 'false')}]}
    when 'nag_mode' # Turning on Nag Mode
      @nag_mode = NagMode.find params[:id]
      @item_being_purchased = @nag_mode
      @program = Program.find params[:optional_id]
      @optional_id = @program.id if @program.present?
      @cancel_url = {:controller => :profile, :action => :user_info, :id => :nag_mode}
      payment_details.merge!({:type => 'nag_mode',
                              :redirect_url => "/store/payment_confirm/#{@nag_mode.id}/nag_mode/#{@program.id}",
                              :amount => @nag_mode.price})

      @kissmetrics[:record] << {:name => "Entered payment pipeline", 
                                :properties => [{:name => 'Purchase Type', :value => params[:type]},
                                                {:name => 'Name', :value => @nag_mode.name},
                                                {:name => 'Price', :value => @nag_mode.price},
                                                {:name => 'Logged In', :value => (current_user ? 'true' : 'false')}]}
    end
  
    if current_user
      @customer = Braintree::Customer.find(current_user.id.to_s) rescue nil

      if @customer.present?
        # Default to their newest credit card if they have one.
        if @customer.credit_cards.present?
          @credit_card = @customer.credit_cards.first
        end

      else
        @customer = Braintree::Customer.create!(
          :id => current_user.id,
          :first_name => current_user.name,
          :email => current_user.email,
          :phone => current_user.phone)
      end

      # Prepare Braintree for some CC information if we don't have a card already
      if @credit_card.blank? or params[:enter_new_card].present?
        @braintree_transparent_redirect_data = Braintree::TransparentRedirect.transaction_data(
          :redirect_url => "https://#{SECURE_DOMAIN}#{payment_details[:redirect_url]}",
          :transaction => {
            :customer_id => @customer.id,
            :type => 'sale',
            :amount => payment_details[:amount],
            :merchant_account_id => 'budge'
          })    
          
      end
    end
  end
  
  # Use a saved Braintree::CreditCard by its token
  def pay_with_card
    if params[:type] == 'program'
      @item_purchased = Program.find params[:id]
      @program_budge = ProgramBudge.find(params[:optional_id]) if params[:optional_id].present?
      @optional_id = @program_budge.present? ? @program_budge.id : nil
      @cancel_url = {:controller => :store, :action => :program, :id => @item_purchased.token}
    elsif params[:type] == 'program_coach'
      @item_purchased = ProgramCoach.find params[:id]    
      @cancel_url = {:controller => :play, :action => :onboarding, :id => @item_purchased.program.id, :anchor => 'coaches'}
    elsif params[:type] == 'nag_mode'
      @item_purchased = NagMode.find params[:id]    
      @program = Program.find(params[:optional_id]) if params[:optional_id].present?
      @optional_id = @program.present? ? @program.id : nil
      @cancel_url = {:controller => :profile, :action => :user_info, :id => :nag_mode}
    end
    @customer = Braintree::Customer.find(current_user.id.to_s) rescue nil

    # Default to their newest credit card if they have one.
    if @customer and @customer.credit_cards.present? and params[:credit_card].present?
      @credit_card = @customer.credit_cards.select{|c|c.token == params[:credit_card][:token]}.first
    end
    
    if @credit_card.present? 
      if @item_purchased.present? 
        unless params[:type] == 'program_coach'
          @authorize = Braintree::CreditCard.sale(@credit_card.token, 
                                                  :amount => @item_purchased.price,
                                                  :merchant_account_id => 'budge')
        end

        settle_purchase
      end
    else
      flash[:kissmetrics_record] ||= Array.new
      flash[:kissmetrics_record] << {:name => "Payment failed"} 
      redirect_to :action => :pay, :id => @item_purchased.id, :type => params[:type], :error => "Unable to pay with that card. Try entering a new one."        
    end
  end
  
  def pay_with_budge_dollars
    if params[:type] == 'program'
      @item_purchased = Program.find params[:id]
      @cancel_url = {:controller => :store, :action => :program, :id => @item_purchased.token}
    elsif params[:type] == 'program_coach'
      @item_purchased = ProgramCoach.find params[:id]    
      @cancel_url = {:controller => :play, :action => :program, :id => @item_purchased.program.id}
    elsif params[:type] == 'nag_mode'
      @item_purchased = NagMode.find params[:id]    
      @cancel_url = {:controller => :profile, :action => :user_info, :id => :nag_mode}
    end
    
    if @item_purchased.present? and @item_purchased.price <= current_user.dollars_credit
      if params[:type] == 'program'
        # @item_purchased is a @program
        program_player = @item_purchased.create_program_player(current_user)
        @program_budge = ProgramBudge.find params[:optional_id] if params[:optional_id].present?

        if program_player.present?
          # Start them on the first level, or the level they chose
          if @program_budge.present?
            program_player.update_attributes(:max_level => @program_budge.level)
            player_budge = program_player.start_budge(@program_budge)
          else
            player_budge = program_player.start_budge(@item_purchased.first_budge)          
          end
          flash[:kissmetrics_record] ||= Array.new
          flash[:kissmetrics_record] << {:name => "Started budge"} 
          
          TrackedAction.add(:paid_via_budge_dollars, current_user)
          current_user.update_attributes(:dollars_credit => current_user.dollars_credit-@item_purchased.price)

          flash[:kissmetrics_set] ||= Array.new
          flash[:kissmetrics_set] << {:name => "Billing Amount", :value => @item_purchased.price}
          flash[:kissmetrics_set] << {:name => "Billing Description", :value => "Initial purchase with credit"}
          flash[:kissmetrics_set] << {:name => "Plan Name", :value => @item_purchased.name}

          flash[:kissmetrics_record] << {:name => "Purchase succeeded"}

          flash[:message] = "Welcome to #{program_player.program.name}!"
          redirect_to :protocol => 'http://', :host => DOMAIN, :controller => :play, :action => :program, :id => program_player.program.id
        else
          flash[:kissmetrics_record] ||= Array.new
          flash[:kissmetrics_record] << {:name => "Purchase failed"} 
          redirect_to :action => :pay, :id => @item_purchased.id, :error => "Unable to create program player.", :type => params[:type], :optional_id => (@program_budge.present? ? @program_budge.id : nil)
        end
      
      elsif params[:type] == 'program_coach'
        program_player = @item_purchased.program.program_players.where(:user_id => current_user.id).first
        purchase_successful = program_player.buy_coach(@item_purchased)
        
        if program_player.present?
          TrackedAction.add(:paid_via_budge_dollars, current_user)
          current_user.update_attributes(:dollars_credit => current_user.dollars_credit-@item_purchased.price)

          flash[:kissmetrics_set] ||= Array.new
          flash[:kissmetrics_set] << {:name => "Billing Amount", :value => @item_purchased.price}
          flash[:kissmetrics_set] << {:name => "Billing Description", :value => "Started coach subscription with credit"}
          flash[:kissmetrics_set] << {:name => "Plan Name", :value => "#{@item_purchased.user.twitter_username} for #{program_player.program.name}"}
          
          flash[:kissmetrics_record] ||= Array.new
          flash[:kissmetrics_record] << {:name => "Purchase succeeded"}
          flash[:kissmetrics_record] << {:name => "Upgraded"}

          flash[:message] = "You now have a coach!"
          redirect_to :protocol => 'http://', :host => DOMAIN, :controller => :play, :action => :program, :id => program_player.program.id        
        else
          @charge.update_attributes({:error_message => "Unable to create program player."})
          flash[:kissmetrics_record] ||= Array.new
          flash[:kissmetrics_record] << {:name => "Purchase failed"} 
          redirect_to :action => :pay, :id => @item_purchased.id, :error => "Unable to create program player.", :type => params[:type]
        end
      
      elsif params[:type] == 'nag_mode'
        # @item_purchased is a @nag_mode
        # 
        @program = Program.find params[:optional_id]
        @program_player = current_user.program_players.where(:program_id => @program).first
        raise "Need to specify program to turn nag mode on for" unless @program.present? and @program_player.present?
        
        if current_user.nag_mode_is_on?
          flash[:message] = "Nag Mode is already on!"
          redirect_to :protocol => 'http://', :host => DOMAIN, :controller => :profile, :action => :user_info, :id => :nag_mode
          
        else
          @user_nag_mode = UserNagMode.start_nag_mode(@item_purchased, @program_player)

          if @user_nag_mode.present?
            TrackedAction.add(:paid_via_budge_dollars, current_user)
            current_user.update_attributes(:dollars_credit => current_user.dollars_credit-@item_purchased.price)
    
            flash[:kissmetrics_set] ||= Array.new
            flash[:kissmetrics_set] << {:name => "Billing Amount", :value => @item_purchased.price}
            flash[:kissmetrics_set] << {:name => "Billing Description", :value => "Initial purchase with credit"}
            flash[:kissmetrics_set] << {:name => "Plan Name", :value => @item_purchased.name}
    
            flash[:kissmetrics_record] ||= Array.new
            flash[:kissmetrics_record] << {:name => "Purchase succeeded"}
    
            flash[:message] = "Welcome to Nag Mode!"
          else
            flash[:message] = "Nag Mode wasn't turned on."          
          end
          redirect_to :protocol => 'http://', :host => DOMAIN, :controller => :profile, :action => :user_info, :id => :nag_mode
        end
      end

    else
      flash[:kissmetrics_record] ||= Array.new
      flash[:kissmetrics_record] << {:name => "Payment failed"} 
      redirect_to :action => :pay, :id => @item_purchased.id, :type => params[:type], :error => "Unable to pay with Budge credit. Try again."        
    end
  end

  # Post a new transaction to Braintree, save it and everything, then they return us here
  def authorization_confirm    
    # Attempt to authorize
    
    if request.query_string.present?
      @authorize = Braintree::TransparentRedirect.confirm(request.query_string)
    end
    # Authorize the card
    if @authorize.present? and @authorize.success?
      current_user.update_attributes({:has_braintree => true})
      TrackedAction.add(:added_credit_card, current_user)
      flash[:kissmetrics_record] ||= Array.new
      flash[:kissmetrics_record] << {:name => "Authorization succeeded"} 
      redirect_to :protocol => 'http://', :host => DOMAIN, :controller => :profile, :action => :settings
    else
      logger.warn "Message: #{@authorize.message}"
      if @authorize.transaction.nil?
        # validation errors prevented transaction from being created
        logger.warn @authorize.errors.inspect
        flash[:kissmetrics_record] ||= Array.new
        flash[:kissmetrics_record] << {:name => "Authorization failed"} 
        redirect_to :action => :pay, :error => @authorize.message, :type => params[:type]
      else
        logger.warn "Transaction ID: #{@authorize.transaction.id}"
        # status will be processor_declined, gateway_rejected, or failed
        logger.warn "Transaction Status: #{@authorize.transaction.status}"
        flash[:kissmetrics_record] ||= Array.new
        flash[:kissmetrics_record] << {:name => "Authorization failed"} 
        redirect_to :action => :pay, :error => @authorize.message, :type => params[:type]
      end
    end  
  end
  
  # Post a new transaction to Braintree, save it and everything, then they return us here
  def payment_confirm
    if params[:type] == 'program'
      @item_purchased = Program.find params[:id]    
    elsif params[:type] == 'program_coach'
      @item_purchased = ProgramCoach.find params[:id]
      @program_budge = ProgramBudge.find params[:optional_id] if params[:optional_id].present?
      @optional_id = @program_budge.present? ? @program_budge.id : nil
    elsif params[:type] == 'nag_mode'
      @item_purchased = NagMode.find params[:id]
      @program = Program.find params[:optional_id] if params[:optional_id].present?
      @optional_id = @program.present? ? @program.id : nil
    end

    # Attempt to authorize
    @authorize = Braintree::TransparentRedirect.confirm(request.query_string)
    if @item_purchased.present? 
      settle_purchase
    else
      raise "No item specified to purchase"
    end
  end
  
  #### COPIED FROM braintree_confirm ####
  # I need to move this into a model of some sort
  # Requires authorization to have already happened in @authorize
  # Also needs to be made more generic, to allow for other purchases than just programs
  def settle_purchase
    if params[:type] == 'program'
      # Create a "charge" object from the results of the authorization
      unless @authorize.transaction.nil?
        @existing_charge = Charge.where(:transaction_id => @authorize.transaction.id).first
        
        if @existing_charge
          @charge = @existing_charge
        else
          @charge = Charge.create({:user_id => current_user.id,
                           :amount => @authorize.transaction.amount,
                           :item_name => params[:type],
                           :item_id => @item_purchased.id,
                           :transaction_id => @authorize.transaction.id,
                           :transaction_status => @authorize.transaction.status,
                           :error_message => (!@authorize.success? ? @authorize.message : nil),
                           :last_four => @authorize.transaction.credit_card_details.last_4,
                           :vault_token => @authorize.transaction.credit_card_details.token,
                           :subscription_id => @authorize.transaction.subscription_id})
        end
      end
  
      # Authorize the card
      if @authorize.success?
        current_user.update_attributes({:has_braintree => true})
        TrackedAction.add(:added_credit_card, current_user)
  
        settle = Braintree::Transaction.submit_for_settlement(@charge.transaction_id)
      
        if settle.success?
          @charge.update_attributes({:transaction_status => settle.transaction.status})
          TrackedAction.add(:paid_via_credit_card, current_user)
        
          # @item_purchased is a @program
          program_player = @item_purchased.create_program_player(current_user)

          if program_player.present?
            # Start them on the first level, or the level they chose
            if @program_budge.present?
              program_player.update_attributes(:max_level => @program_budge.level)
              player_budge = program_player.start_budge(@program_budge)
            else
              player_budge = program_player.start_budge(@item_purchased.first_budge)          
            end

            flash[:kissmetrics_set] ||= Array.new
            flash[:kissmetrics_set] << {:name => "Billing Amount", :value => @item_purchased.price}
            flash[:kissmetrics_set] << {:name => "Billing Description", :value => "Initial purchase"}
            flash[:kissmetrics_set] << {:name => "Plan Name", :value => @item_purchased.name}

            flash[:kissmetrics_record] ||= Array.new
            flash[:kissmetrics_record] << {:name => "Purchase succeeded"}
            flash[:kissmetrics_record] << {:name => "Started budge"} 

            flash[:message] = "Welcome to #{program_player.program.name}!"
            redirect_to :protocol => 'http://', :host => DOMAIN, :controller => :play, :action => :program, :id => program_player.program.id
          else
            @charge.update_attributes({:error_message => "Unable to create program player."})
            flash[:kissmetrics_record] ||= Array.new
            flash[:kissmetrics_record] << {:name => "Purchase failed"} 
            redirect_to :action => :pay, :id => @item_purchased.id, :error => "Unable to create program player.", :type => params[:type], :optional_id => (@program_budge.present? ? @program_budge.id : nil)
          end

        elsif settle.transaction.present?
          @charge.update_attributes({:error_message => settle.message,
                                     :transaction_status => settle.transaction.status})
          flash[:kissmetrics_record] ||= Array.new
          flash[:kissmetrics_record] << {:name => "Purchase failed"} 
          redirect_to :action => :pay, :id => @item_purchased.id, :error => settle.message, :type => params[:type], :optional_id => (@program_budge.present? ? @program_budge.id : nil)
        else
          @charge.update_attributes({:error_message => settle.message, 
                                     :transaction_status => nil})
          flash[:kissmetrics_record] ||= Array.new
          flash[:kissmetrics_record] << {:name => "Purchase failed"} 
          redirect_to :action => :pay, :id => @item_purchased.id, :error => settle.message, :type => params[:type], :optional_id => (@program_budge.present? ? @program_budge.id : nil)
        end
      end


    elsif params[:type] == 'program_coach'

      if @customer.blank? or @credit_card.blank?
        @customer = Braintree::Customer.find(current_user.id.to_s) rescue nil
  
        if @customer.present?
          # Default to their newest credit card if they have one.
          if @customer.credit_cards.present?
            @credit_card = @customer.credit_cards.first
          end
        end
      end
    
      @result = Braintree::Subscription.create(
                    :merchant_account_id => "budge",
                    :payment_method_token => @credit_card.token,
                    :plan_id => "coach-subscription",
                    :price => @item_purchased.price,
                    :options => {:start_immediately => true})        

      logger.warn @result.inspect
      @transaction = @result.subscription.transactions.first rescue nil
      if @result.subscription and @result.subscription.status == 'Active'
        
        # Create a "charge" object from the results of the authorization
        @existing_charge = Charge.where(:transaction_id => @transaction.id).first
        
        if @existing_charge
          @charge = @existing_charge
        else
          @charge = Charge.create({:user_id => current_user.id,
                           :amount => @item_purchased.price,
                           :item_name => params[:type],
                           :item_id => @item_purchased.id,
                           :transaction_id => @transaction.id,
                           :transaction_status => @transaction.status,
                           :error_message => (!@result.success? ? @transaction.message : nil),
                           :last_four => @transaction.credit_card_details.last_4,
                           :vault_token => @transaction.credit_card_details.token,
                           :subscription_id => @result.subscription.id})
        end

        program_player = current_user.program_players.where(:program_id => @item_purchased.program_id).first
        purchase_successful = program_player.buy_coach(@item_purchased, @charge, @result.subscription) if program_player.present?
        
        if purchase_successful
          # Notify coach and player about the fact that they have a new relationship

          if program_player.present?
            flash[:kissmetrics_set] ||= Array.new
            flash[:kissmetrics_set] << {:name => "Billing Amount", :value => @item_purchased.price}
            flash[:kissmetrics_set] << {:name => "Billing Description", :value => "Started coach subscription"}
            flash[:kissmetrics_set] << {:name => "Plan Name", :value => "#{@item_purchased.user.twitter_username} for #{program_player.program.name}"}
            
            flash[:kissmetrics_record] ||= Array.new
            flash[:kissmetrics_record] << {:name => "Purchase succeeded"}
  
            flash[:message] = "You now have a coach!"
            redirect_to :protocol => 'http://', :host => DOMAIN, :controller => :play, :action => :program, :id => program_player.program.id
          else
            @charge.update_attributes({:error_message => "Can't buy coach because they don't have this program."})
            flash[:kissmetrics_record] ||= Array.new
            flash[:kissmetrics_record] << {:name => "Purchase failed"} 
            redirect_to :action => :pay, :id => @item_purchased.id, :error => "Can't buy coach because they don't have this program.", :type => params[:type]
          end
        else
          @charge.update_attributes({:error_message => "Can't buy coach because the program wasn't saved."})
          flash[:kissmetrics_record] ||= Array.new
          flash[:kissmetrics_record] << {:name => "Purchase failed"} 
          redirect_to :action => :pay, :id => @item_purchased.id, :error => "Can't buy coach because the program wasn't saved.", :type => params[:type]        
        end
      else
        #@charge.update_attributes({:error_message => @result.message,
        #                           :transaction_status => (@transaction.present? ? @transaction.status : "Subscription failed.")})
        flash[:kissmetrics_record] ||= Array.new
        flash[:kissmetrics_record] << {:name => "Purchase failed"} 
        redirect_to :action => :pay, :id => @item_purchased.id, :error => @result.message, :type => params[:type]          
      end


    elsif params[:type] == 'nag_mode'
      # Create a "charge" object from the results of the authorization
      unless @authorize.transaction.nil?
        @existing_charge = Charge.where(:transaction_id => @authorize.transaction.id).first
        
        if @existing_charge
          @charge = @existing_charge
        else
          @charge = Charge.create({:user_id => current_user.id,
                           :amount => @authorize.transaction.amount,
                           :item_name => params[:type],
                           :item_id => @item_purchased.id,
                           :transaction_id => @authorize.transaction.id,
                           :transaction_status => @authorize.transaction.status,
                           :error_message => (!@authorize.success? ? @authorize.message : nil),
                           :last_four => @authorize.transaction.credit_card_details.last_4,
                           :vault_token => @authorize.transaction.credit_card_details.token,
                           :subscription_id => @authorize.transaction.subscription_id})
        end
      end
  
      # Authorize the card
      if @authorize.success?
        current_user.update_attributes({:has_braintree => true})
        TrackedAction.add(:added_credit_card, current_user)
  
        settle = Braintree::Transaction.submit_for_settlement(@charge.transaction_id)
      
        if settle.success?
          @charge.update_attributes({:transaction_status => settle.transaction.status})
          TrackedAction.add(:paid_via_credit_card, current_user)
        
          # @item_purchased is a @nag_mode
          program_player = current_user.program_players.where(:program_id => @program.id).first

          if program_player.present? and user_nag_mode = UserNagMode.start_nag_mode(@item_purchased, program_player)
            flash[:kissmetrics_set] ||= Array.new
            flash[:kissmetrics_set] << {:name => "Billing Amount", :value => @item_purchased.price}
            flash[:kissmetrics_set] << {:name => "Billing Description", :value => "Initial purchase"}
            flash[:kissmetrics_set] << {:name => "Plan Name", :value => @item_purchased.name}

            flash[:kissmetrics_record] ||= Array.new
            flash[:kissmetrics_record] << {:name => "Purchase succeeded"}
            flash[:kissmetrics_record] << {:name => "Started budge"} 

            flash[:message] = "Nag Mode has been turned on!"
            redirect_to :protocol => 'http://', :host => DOMAIN, :controller => :profile, :action => :user_info, :id => :nag_mode
            
          else
            @charge.update_attributes({:error_message => "Unable to turn on Nag Mode."})
            flash[:kissmetrics_record] ||= Array.new
            flash[:kissmetrics_record] << {:name => "Purchase failed"} 
            redirect_to :action => :pay, :id => @item_purchased.id, :error => "Unable to turn on Nag Mode.", :type => params[:type], :optional_id => (@optional_id.present? ? @optional_id : nil)
          end

        elsif settle.transaction.present?
          @charge.update_attributes({:error_message => settle.message,
                                     :transaction_status => settle.transaction.status})
          flash[:kissmetrics_record] ||= Array.new
          flash[:kissmetrics_record] << {:name => "Purchase failed"} 
          redirect_to :action => :pay, :id => @item_purchased.id, :error => settle.message, :type => params[:type], :optional_id => (@optional_id.present? ? @optional_id : nil)
        else
          @charge.update_attributes({:error_message => settle.message, 
                                     :transaction_status => nil})
          flash[:kissmetrics_record] ||= Array.new
          flash[:kissmetrics_record] << {:name => "Purchase failed"} 
          redirect_to :action => :pay, :id => @item_purchased.id, :error => settle.message, :type => params[:type], :optional_id => (@optional_id.present? ? @optional_id : nil)
        end
      end
    
    else
      raise "Invalid purchase type."
    end
  end
  
  def cancel_subscription_id
    if params[:id].present?
      @program_player = ProgramPlayer.find_by_program_coach_subscription_id(params[:id]) rescue nil
    elsif params[:program_player_id].present?
      @program_player = ProgramPlayer.find params[:program_player_id]
    end
    raise "Invalid user. #{@program_player.inspect} == #{current_user.inspect}" unless @program_player.present? and current_user.id == @program_player.user_id
    
    @program_player.end_coach_subscription

    flash[:kissmetrics_record] ||= Array.new
    flash[:kissmetrics_record] << {:name => "Downgraded"}
    
    # http://beta.getbudged.com/profile/user_info/coaches?redirect_to=%2Fprofile%2Fsettings
    flash[:message] = "Coach subscription canceled"
    if params[:redirect_to]
      redirect_to params[:redirect_to]
    else
      redirect_to :controller => :profile, :action => :settings    
    end
  end

  # Collect payment
  def payment
  end
    
  private 
  
  # Used to parse countries from Braintree's list, for cc processing
  def parse_countries
    @countries = Hash.new
    File.open('/home/betag/budge/countries-from-braintree.txt') do |f|
      
      while (line = f.gets)
        split_line = line.split(' ')
        code = split_line.pop
        l1 = split_line.pop
        l2 = split_line.pop
        @countries[split_line.join(' ')] = {:short => l2, :long => l1, :name => split_line.join(' '), :code => code}
      end
    end
  end
  
  
end

