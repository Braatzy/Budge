require "linguistics"

class Trait < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  Linguistics.use :en
  
  has_many :pack_traits, :dependent => :destroy
  has_many :packs, :through => :pack_traits    
  has_many :user_traits, :dependent => :destroy
  has_many :user, :through => :user_traits    
  acts_as_tree :foreign_key => :parent_trait_id
  before_save :pluralize_nouns

  CHECKIN_TRAIT = {'eat' => 'share_meal',
                   'pushups' => 'pushups',
                   'push-ups' => 'pushups',
                   'planked' => 'plank'}
   
  # tenses: :past, :present, :past_participle, :present_participle
  # other_verbs: other verbs to catch in a text check in
  # textable: whether or not we'll create a checkin if we see this verb in an sms or tweet
  TENSES = {
    'add' => {:past => 'added', :present => 'adds', :past_participle => 'added', :present_participle => 'adding'},
    'answer' => {:past => 'answered', :present => 'answers', :past_participle => 'answered', :present_participle => 'answering'},
    'bring' => {:past => 'brought', :present => 'brings', :past_participle => 'brought', :present_participle => 'bringing'},
    'buy' => {:past => 'bought', :present => 'buys', :past_participle => 'brought', :present_participle => 'buying'},
    'call' => {:past => 'called', :present => 'calls', :past_participle => 'called', :present_participle => 'calling'},
    'car pool' => {:past => 'car pooled', :present => 'car pools', :past_participle => 'car pooled', :present_participle => 'car pooling'},
    'check in' => {:past => 'checked in', :present => 'checks in', :past_participle => 'checked in', :present_participle => 'checking in'},
    'choose' => {:past => 'chose', :present => 'chooses', :past_participle => 'chose', :present_participle => 'choosing'},
    'commute' => {:past => 'commuted', :present => 'commutes', :past_participle => 'commuted', :present_participle => 'commuting'},
    'contact' => {:past => 'contacted', :present => 'contacts', :past_participle => 'contacted', :present_participle => 'contacting'},
    'cook' => {:past => 'cooked', :present => 'cooks', :past_participle => 'cooked', :present_participle => 'cooking'},
    'do' => {:past => 'did', :present => 'does', :past_participle => 'done', :present_participle => 'doing'},
    'donate' => {:past => 'donated', :present => 'donates', :past_participle => 'donated', :present_participle => 'donating'},
    'drink' => {:past => 'drank', :present => 'drinks', :past_participle => 'drunk', :present_participle => 'drinking'},
    'drive' => {:past => 'drove', :present => 'drives', :past_participle => 'driven', :present_participle => 'driving'},
    'eat' => {:past => 'ate', :present => 'eats', :past_participle => 'eaten', :present_participle => 'eating'},
    'email' => {:past => 'emailed', :present => 'emails', :past_participle => 'emailed', :present_participle => 'emailing'},
    'floss' => {:past => 'flossed', :present => 'flosses', :past_participle => 'flossed', :present_participle => 'flossing'},
    'follow' => {:past => 'followed', :present => 'follows', :past_participle => 'followed', :present_participle => 'following'},
    'get' => {:past => 'got', :present => 'gets', :past_participle => 'gotten', :present_participle => 'getting'},
    'go' => {:past => 'went', :present => 'goes', :past_participle => 'gone', :present_participle => 'going'},
    'go on' => {:past => 'went on', :present => 'goes on', :past_participle => 'gone on', :present_participle => 'going on'},
    'go to' => {:past => 'went to', :present => 'goes to', :past_participle => 'gone to', :present_participle => 'going to'},
    'have' => {:past => 'had', :present => 'has', :past_participle => 'had', :present_participle => 'having'},
    'have sex' => {:past => 'had sex', :present => 'has sex', :past_participle => 'had sex', :present_participle => 'having sex'},
    'help' => {:past => 'helped', :present => 'helps', :past_participle => 'helped', :present_participle => 'helping'},
    'hi-5' => {:past => "hi-5'ed", :present => 'hi-5s', :past_participle => "hi-5'ed", :present_participle => 'hi-5ing'},
    'hug' => {:past => 'hugged', :present => 'hugs', :past_participle => 'hugged', :present_participle => 'hugging'},
    'keep' => {:past => 'kept', :present => 'keeps', :past_participle => 'kept', :present_participle => 'keeping'},
    'kiss' => {:past => 'kissed', :present => 'kisses', :past_participle => 'kissed', :present_participle => 'kissing'},
    'leave' => {:past => 'left', :present => 'leaves', :past_participle => 'left', :present_participle => 'leaving'},
    'listen to' => {:past => 'listened to', :present => 'listens to', :past_participle => 'listened to', :present_participle => 'listening to'},
    'meditate' => {:past => 'meditated', :present => 'meditates', :past_participle => 'meditated', :present_participle => 'meditating', :other_verbs => ['meditation']},
    'pack' => {:past => 'packed', :present => 'packs', :past_participle => 'packed', :present_participle => 'packing'},
    'plan' => {:past => 'planned', :present => 'planned', :past_participle => 'planned', :present_participle => 'planning'},
    'play' => {:past => 'played', :present => 'plays', :past_participle => 'played', :present_participle => 'playing'},
    'practice' => {:past => 'practiced', :present => 'practices', :past_participle => 'practiced', :present_participle => 'practicing'},
    'post on' => {:past => 'posted on', :present => 'posts on', :past_participle => 'posted on', :present_participle => 'posting'},
    'read' => {:past => 'read', :present => 'reads', :past_participle => 'read', :present_participle => 'reading'},
    'relax' => {:past => 'relaxed', :present => 'relaxes', :past_participle => 'relaxed', :present_participle => 'relaxing'},
    'ride' => {:past => 'rode', :present => 'rides', :past_participle => 'ridden', :present_participle => 'riding'},
    'run' => {:past => 'ran', :present => 'runs', :past_participle => 'run', :present_participle => 'running'},
    'save' => {:past => 'saved', :present => 'saves', :past_participle => 'saved', :present_participle => 'saving'},
    'see' => {:past => 'saw', :present => 'sees', :past_participle => 'seen', :present_participle => 'seeing'},
    'set' => {:past => 'set', :present => 'set', :past_participle => 'set', :present_participle => 'setting'},
    'share' => {:past => 'shared', :present => 'shares', :past_participle => 'shared', :present_participle => 'sharing'},
    'smoke' => {:past => 'smoked', :present => 'smokes', :past_participle => 'smoked', :present_participle => 'smoking'},
    'socialize' => {:past => 'socialized', :present => 'socializes', :past_participle => 'socialized', :present_participle => 'socializing'},
    'spend' => {:past => 'spent', :present => 'spends', :past_participle => 'spent', :present_participle => 'spending'},
    'stay' => {:past => 'stayed', :present => 'stays', :past_participle => 'stayed', :present_participle => 'staying'},
    'stretch' => {:past => 'stretched', :present => 'stretches', :past_participle => 'stretched', :present_participle => 'stretching'},
    'take' => {:past => 'took', :present => 'takes', :past_participle => 'taken', :present_participle => 'taking'},
    'think' => {:past => 'thought', :present => 'thinks', :past_participle => 'thought', :present_participle => 'thinking'},
    'track' => {:past => 'tracked', :present => 'tracks', :past_participle => 'tracked', :present_participle => 'tracking'},
    'try' => {:past => 'tried', :present => 'tries', :past_participle => 'tried', :present_participle => 'trying'},
    'tweet' => {:past => 'tweeted', :present => 'tweets', :past_participle => 'tweeted', :present_participle => 'tweeting'},
    'use' => {:past => 'used', :present => 'uses', :past_participle => 'used', :present_participle => 'using'},
    'visit' => {:past => 'visited', :present => 'visits', :past_participle => 'visited', :present_participle => 'visiting'},
    'volunteer' => {:past => 'volunteered', :present => 'volunteers', :past_participle => 'volunteered', :present_participle => 'volunteering'},
    'wake up on time' => {:past => 'woke up on time', :present => 'wakes up on time', :past_participle => 'woken up on time', :present_participle => 'waking up on time'},
    'walk' => {:past => 'walked', :present => 'walks', :past_participle => 'walked', :present_participle => 'walking'},
    'walk to' => {:past => 'walked to', :present => 'walks to', :past_participle => 'walked to', :present_participle => 'walking to'},
    'watch' => {:past => 'watched', :present => 'watches', :past_participle => 'watched', :present_participle => 'watching'},
    'wear' => {:past => 'wore', :present => 'wears', :past_participle => 'worn', :present_participle => 'wearing'},
    'weigh in' => {:past => 'weighed in', :present => 'weighs in', :past_participle => 'weighed in', :present_participle => 'weighing in', :other_verbs => ['weigh', 'weighed']},
    'write in' => {:past => 'wrote in', :present => 'writes in', :past_participle => 'written in', :present_participle => 'writing in'},
    'write' => {:past => 'wrote', :present => 'writes', :past_participle => 'written', :present_participle => 'writing'}
  }
  
  ANSWER_TYPE  = {':boolean'  => {:cumulative => true,
                                  :zero_equals_no_action => true,
                                  :complete_when => :num_days_done,
                                  :include_question => false,
                                  :unit => 'time', :units => 'times', 
                                  :alt => []},
                  ':quantity' => {:cumulative => true,
                                  :zero_equals_no_action => true,
                                  :complete_when => :sum_of_amount,
                                  :include_question => false,
                                  :unit => 'time', :units => 'times', 
                                  :alt => []},
                  ':pounds'   => {:cumulative => false,
                                  :zero_equals_no_action => false,
                                  :complete_when => :num_days_done,
                                  :include_question => false,
                                  :unit => 'time', :units => 'times', 
                                  :alt => ['pound','pounds','lb','lbs','kilo','kilos','kilograms','kilogram','kg','kgs']},
                  ':miles'    => {:cumulative => true,
                                  :zero_equals_no_action => true,
                                  :complete_when => :sum_of_amount,
                                  :include_question => false,
                                  :unit => ':mile', :units => ':miles', 
                                  :alt => ['mile','miles','mi','mis','kilometer','kilometers','km','kms']},
                  ':minutes'  => {:cumulative => true,
                                  :zero_equals_no_action => true,
                                  :complete_when => :sum_of_amount,
                                  :include_question => false,
                                  :unit => 'minute', :units => 'minutes', 
                                  :alt => ['minute','minutes','min','mins']},
                  ':seconds'  => {:cumulative => true,
                                  :zero_equals_no_action => true,
                                  :complete_when => :sum_of_amount,
                                  :include_question => false,
                                  :unit => 'second', :units => 'seconds', 
                                  :alt => ['second','seconds','sec','secs']},
                  ':steps'    => {:cumulative => true,
                                  :zero_equals_no_action => true,
                                  :complete_when => :sum_of_amount,
                                  :include_question => false,
                                  :unit => 'step', :units => 'steps', 
                                  :alt => ['step','steps']},
                  ':text'     => {:cumulative => true,
                                  :zero_equals_no_action => true,
                                  :complete_when => :num_days_done,
                                  :include_question => true,
                                  :unit => 'time', :units => 'times', 
                                  :alt => []},
                  ':time'     => {:cumulative => true,
                                  :zero_equals_no_action => true,
                                  :complete_when => :num_days_done,
                                  :include_question => true,
                                  :unit => 'time', :units => 'times', 
                                  :alt => ['time','times']},
                  ':days'     => {:cumulative => true,
                                  :zero_equals_no_action => true,
                                  :complete_when => :num_days_done,
                                  :include_question => false,
                                  :unit => 'day', :units => 'days', 
                                  :alt => ['day','days']}}

  def self.action_object_hash
    @hash = Hash.new
    Trait.all.each do |trait|
      noun = trait.noun.present? ? trait.noun : '[empty]'
      @hash[trait.verb] ||= Hash.new
      @hash[trait.verb][noun] ||= 0
      @hash[trait.verb][noun] += 1      
    end
    p @hash.to_yaml
    return @hash
  end
  
  def self.string_to_verb_hash
    @hash = Hash.new
    return @hash if @hash.present?
    TENSES.each do |verb, tense_hash|
      @hash[verb] = verb
      @hash[tense_hash[:present]] = verb
      @hash[tense_hash[:past]] = verb
      @hash[tense_hash[:past_participle]] = verb
      @hash[tense_hash[:present_participle]] = verb
      if tense_hash[:other_verbs].present?
        tense_hash[:other_verbs].each do |v|
          @hash[v] = verb        
        end
      end
    end
    return @hash
  end
  # Special methods for particular verbs and traits
  def self.verb_to_checkin_trait(verb)
    Trait.where(:token => CHECKIN_TRAIT[verb]).first
  end
  def self.string_to_answer_type_hash
    @hash = Hash.new
    return @hash if @hash.present?
    ANSWER_TYPE.each do |answer_type, answer_type_hash|
      answer_type_hash[:alt].each do |alt_string|
        @hash[alt_string] = answer_type
      end
    end
    return @hash
  end
  
  # Whether or not data from this trait can be added up into totals
  # ie. weight = false, miles  = true
  def cumulative_results?
    ANSWER_TYPE[self.answer_type][:cumulative] rescue true
  end
  
  # Whether or not an answer of 0 is equivalent to not doing this action 
  # ie. not true for weight, as it implies a weight of 0 rather than not weighing yourself
  def zero_equals_no_action?
    ANSWER_TYPE[self.answer_type][:zero_equals_no_action]
  end
  
  def count_days?
    ANSWER_TYPE[self.answer_type][:complete_when] == :num_days_done
  end
  
  def complete_when
    ANSWER_TYPE[self.answer_type][:complete_when]
  end
  
  def complete_when_num_days_done?
    ANSWER_TYPE[self.answer_type][:complete_when] == :num_days_done
  end

  def complete_when_sum_of_amount?
    ANSWER_TYPE[self.answer_type][:complete_when] == :sum_of_amount
  end
  
  def unit
    ANSWER_TYPE[self.answer_type][:unit]  
  end

  def self.options_for_web_select(user)
    options = []
    
    user.available_budge_packs.each do |pack|
      options << {:id => nil, :name => "--- #{pack.pack_name.upcase} ---", :pack => true}
      pack.traits.sort_by{|t|t.verb.to_s+t.noun.to_s+t.answer_type.to_s}.each do |trait|
        options << {:id => trait.id, :name => " - #{trait.verb} - #{trait.noun} - #{trait.answer_type}"} if trait.verb.present?
      end
      options << {:id => nil, :name => "", :pack => true}
    end

    return options.map{|o|[o[:name], o[:id]]}
  end  
  
  def statement_from_metadata(user, total, num_results, percentage_change = nil)
    statement_hash = {:pre_text => nil, :amount => nil, :post_text => nil}
    if self.cumulative_results?
      if self.answer_type == ':seconds'
        if total > 60
          minutes = (total/60.0).floor
          seconds = total - (minutes*60)
          seconds = "0#{seconds}" if seconds < 10
          statement_hash[:amount] = "#{minutes}:#{seconds}"
          statement_hash[:post_text] = "minutes"
        else
          statement_hash[:amount] = total
          statement_hash[:post_text] = total == 1 ? 'second' : 'seconds'        
        end
      elsif self.noun.blank? 
        statement_hash[:amount] = total
        if self.answer_type == ':minutes'
          statement_hash[:post_text] = total == 1 ? 'min' : 'mins'
        elsif self.answer_type == ':seconds'
          statement_hash[:post_text] = total == 1 ? 'sec' : 'secs'
        elsif self.answer_type == ':miles'
          statement_hash[:post_text] = total == 1 ? user.distance_pref : "#{user.distance_pref}s"
        elsif self.answer_type == ':steps'
          statement_hash[:post_text] = total == 1 ? 'step' : 'steps'
        else
          statement_hash[:post_text] = total == 1 ? 'time' : 'times'
        end
      elsif self.answer_type == ':text'
        statement_hash[:amount] = num_results
        statement_hash[:post_text] = num_results == 1 ? self.noun : self.noun.pluralize
      else
        statement_hash[:amount] = total
        statement_hash[:post_text] = total == 1 ? self.noun : self.noun.pluralize
      end
    else
      if self.answer_type == ':pounds'
        if num_results.to_i > 0 and percentage_change.to_f != 0
          average_weight = total/num_results.to_f
          change_in_weight = (average_weight * (percentage_change/100.0)) rescue 0.0
          change_in_weight = (change_in_weight.abs*100).to_i/100.0
        else
          num_results ||= 0
          percentage_change ||= 0
          average_weight = total
          change_in_weight = 0
        end
        if percentage_change.present?
          if percentage_change < 0
            if percentage_change > -100
              statement_hash[:amount] = change_in_weight 
              statement_hash[:post_text] = "#{user.weight_pref} lost"
            else
              statement_hash[:post_text] = 'way down'
            end
          elsif percentage_change > 0
            if percentage_change < 500
              statement_hash[:amount] = change_in_weight
              statement_hash[:post_text] = "#{user.weight_pref} gained"
            else
              statement_hash[:post_text] = 'way up'
            end
          else
            statement_hash[:pre_text] = 'Remaining'
            statement_hash[:post_text] = 'stable'
          end
        elsif num_results and num_results > 0
          statement_hash[:amount] = (total*100/num_results).to_i/100.0
          statement_hash[:post_text] = "#{self.unit} avg"
        end
      end
    end
    return statement_hash
  end
  
  # NOTES
  # In trait.noun, any words beginning with *, like *cup, need to be pluralized instead of the full noun
  # Don't pluralize nouns that end in s
  # new traits: eat, thing, :quantity - watch, television :minutes
  # Need to add noun_plural to spreadsheet
  # Boolean answer_types always go:  "#{tensed verb} #{article} #{noun} #{quantity} #{answer_type units}
  # Quantity answer_types always go: "#{tensed verb} #{article or quantity} #{noun} #{answer_type units}
  # :pounds acts like half boolean, half quantity.
  def self.statement(user, tense, trait, quantity, checkin = nil, prefer_details = false)
    verb, noun, answer_type = trait.verb, trait.noun, trait.answer_type
    custom_noun = false
    if noun.present? and checkin.present?
      if checkin.user_action.present? and checkin.user_action.custom_text.present?
        noun = checkin.user_action.custom_text
        custom_noun = true
      end
    end
    noun_pl ||= trait.noun_pl
    if TENSES[verb].present? and TENSES[verb][tense].present? and ANSWER_TYPE[answer_type].present?
      if tense == :past
        @string = "#{TENSES[verb][tense]}"
        if quantity.to_i == quantity.to_f
          quantity = quantity.to_i
        else
          quantity = (quantity * 100).to_i/100.0
        end
        if checkin.present? 
          if checkin.amount_decimal.to_i == checkin.amount_decimal.to_f
            amount_rounded = quantity.to_i
          else
            amount_rounded = (checkin.amount_decimal * 100).to_i/100.0
          end
        else
          amount_rounded = quantity.to_i
        end
        if quantity == 0 and trait.zero_equals_no_action?
          if answer_type == ':quantity' # drank 5 coca colas
            if custom_noun
              noun_pl = noun.en.plural
            else
              noun_pl = trait.noun_pl            
            end
            @string += " #{quantity} #{noun_pl}"          
          else
            @string = "didn't #{verb}#{trait.article.present? ? " #{trait.article} " : ' '}#{noun}"
          end
        elsif quantity == 1
          if answer_type == ':boolean' # ate brocoli
            @string += " #{(!custom_noun and trait.article.present?) ? "#{trait.article} " : ''}#{noun}"
          elsif answer_type == ':quantity' # drank 5 coca colas
            @string += " #{(!custom_noun and trait.article.present?) ? "#{trait.article} " : ''}#{noun}"          
          elsif answer_type == ':text' # 
            # This won't happen because quantity is the number of characters in the answer...
          elsif answer_type == ':minutes'
            @string += " #{(!custom_noun and trait.article.present?) ? "#{trait.article} " : ''}#{noun} for #{quantity} #{ANSWER_TYPE[answer_type][:unit]}"          
          elsif answer_type == ':seconds'
            @string += " #{(!custom_noun and trait.article.present?) ? "#{trait.article} " : ''}#{noun} for #{quantity} #{ANSWER_TYPE[answer_type][:unit]}"          
          elsif answer_type == ':time'
            @string += " #{(!custom_noun and trait.article.present?) ? "#{trait.article} " : ''}#{noun}"          
          elsif answer_type == ':miles'          
            @string += " #{quantity} #{user.distance_pref(:long)}"  
          elsif answer_type == ':pounds'          
            @string += " #{(!custom_noun and trait.article.present?) ? "#{trait.article} " : ''}#{noun}" 
            if checkin
              @string += " (#{amount_rounded}#{user.weight_pref})"
            end
          else
            @string += " FIX #{quantity} #{ANSWER_TYPE[answer_type][:unit]}"
          end
        else
          if answer_type == ':boolean'
            @string += " #{(!custom_noun and trait.article.present?) ? "#{trait.article} " : ''}#{noun}"
            @string += " #{quantity} #{ANSWER_TYPE[answer_type][:units]}" unless quantity == 0
          elsif answer_type == ':quantity'
            if custom_noun
              noun_pl = noun.en.plural
            else
              noun_pl = trait.noun_pl            
            end
            @string += " #{quantity} #{noun_pl}"          
          elsif answer_type == ':text'
            # Only show the answer
            if prefer_details and checkin.present? and checkin.user_action.present? and checkin.user_action.program_action_template.present?
              if trait.past_template.present? 
                @string = trait.past_template.gsub("[answer]",checkin.amount_text)
              else
                @string = "Q: &#8220;#{checkin.user_action.program_action_template.daily_question}&#8221; A: &#8220;#{checkin.amount_text}&#8221;"
              end
            else
              if checkin
                @string += " #{(!custom_noun and trait.article.present?) ? "#{trait.article} " : ''}#{trait.noun}"
              else
                @string += " #{(!custom_noun and trait.article.present?) ? "#{trait.article} " : ''}#{trait.noun}"            
              end
            end
          elsif answer_type == ':minutes'
            @string += " #{(!custom_noun and trait.article.present?) ? "#{trait.article} " : ''}#{noun}"
            @string += " for #{quantity} #{ANSWER_TYPE[answer_type][:units]}" unless quantity == 0

          elsif answer_type == ':seconds'
            @string += " #{(!custom_noun and trait.article.present?) ? "#{trait.article} " : ''}#{noun}"
            if quantity > 60
              minutes = (quantity/60.0).floor
              seconds = quantity - (minutes*60)
              if seconds.present? and seconds < 10
                seconds = "0#{seconds}"
              end
              @string += " for #{minutes}:#{seconds} minutes"
            else
              @string += " for #{quantity} #{ANSWER_TYPE[answer_type][:units]}" unless quantity == 0          
            end

          elsif answer_type == ':time'
            @string += " #{(!custom_noun and trait.article.present?) ? "#{trait.article} " : ''}#{noun}"
            @string += " #{quantity} #{ANSWER_TYPE[answer_type][:units]}" unless quantity == 0

          elsif answer_type == ':miles'
            @string += " #{quantity} #{user.distance_pref(:long)}s"          
          elsif answer_type == ':pounds'         
            if checkin
              @string += " #{(!custom_noun and trait.article.present?) ? "#{trait.article} " : ''}#{noun} (#{amount_rounded} #{user.weight_pref})"
            else
              @string += " #{(!custom_noun and trait.article.present?) ? "#{trait.article} " : ''}#{noun}"
              @string += " #{quantity} #{ANSWER_TYPE[answer_type][:units]}" unless quantity == 0
            end 
           
          else
            @string += " FIX #{quantity} #{ANSWER_TYPE[answer_type][:units]}"
          end
        end
      end
      return @string
    else
      return "Update trait dictionary for #{verb}, Buster."
    end
  end
  
  # checkin_hash should be passed in with the following values already filled in
  # REQUIRED: :amount_decimal, :amount_text, :checkin_via
  # OPTIONAL: :date, :latitude, :longitude, comment, remote_id, :raw_text
  def save_checkins_for_user(user, checkin_hash)

    user_trait = UserTrait.find_or_create_by_trait_id_and_user_id(self.id, user.id)
    time_in_time_zone = Time.zone.now.in_time_zone(user.time_zone_or_default)
    date ||= time_in_time_zone.to_date

    # attributes of the eventual Checkin
    checkin_hash.merge!({:user_id => user.id,
                         :date => date,
                         :is_player => true,
                         :trait_id => self.id,
                         :user_trait_id => user_trait.id,
                         :checkin_datetime => time_in_time_zone,
                         :checkin_datetime_approximate => false})
                    
    checkins = user_trait.save_new_data(checkin_hash, {})
    return checkins  
  end
    
  # DEPRECATED - START # 

  def trait_name 
    if name.present?
      return name
    else
      return "#{self.do_name} / #{self.dont_name}"
    end
  end
  
  # Figure out if the substitution is required, or merely suggested: Watch (a movie) vs Watch [this movie]
  def setup_substitution_type
    return unless self.do_name
    if self.do_name.match(/\((.*)?\)/)
      return :allowed
    elsif self.do_name.match(/\[(.*)?\]/)
      return :required
    end
  end
  
  # The trait name minus any text that we're trying to get from the user: eat _______
  def select_trait_do_label
    return unless self.do_name
    string = self.do_name.dup
    string = Trait.substitute_determiners(string)
    if string.match(/\((.*)?\)/)
      string = string.gsub(/\(.*?\)/,'_____').strip
      return string.length > 0 ? string : 'Specify your custom budge'
    elsif string.match(/\[(.*)?\]/)
      string = string.gsub(/\[.*?\]/,'_____').strip
      return string.length > 0 ? string : 'Specify your custom budge'
    else
      return string
    end      
  end
  def select_trait_dont_label
    return unless self.dont_name
    string = self.dont_name.dup
    string = Trait.substitute_determiners(string)
    if string.match(/\((.*)?\)/)
      string = string.gsub(/\(.*?\)/,'_____').strip
      return string.length > 0 ? string : 'Specify your custom budge'    
    elsif string.match(/\[(.*)?\]/)
      string = string.gsub(/\[.*?\]/,'_____').strip
      return string.length > 0 ? string : 'Specify your custom budge'    
    else
      return string
    end    
  end
  
  # What shows up in the text_field as a suggestion: an alcoholic drink
  def select_trait_do_placeholder
    return unless self.do_name
    if self.do_name.match(/\((.*)?\)/)
      string = $1
      string = Trait.substitute_determiners(string)
    elsif self.do_name.match(/\[(.*)?\]/)
      string = $1
      string = Trait.substitute_determiners(string)
    end    
    return string
  end
  def select_trait_dont_placeholder
    return unless self.dont_name
    if self.dont_name.match(/\((.*)?\)/)
      string = $1
      string = Trait.substitute_determiners(string)
    elsif self.dont_name.match(/\[(.*)?\]/)
      string = $1
      string = Trait.substitute_determiners(string)
    end        
  end
  
  # Trait name with the user-generated text replacing what was our placeholder
  def regex_custom_name(is_a_do, custom_text)
    if is_a_do
      return unless self.do_name
      string = self.do_name.gsub(/\(.*?\)/,custom_text)      
    else
      return unless self.dont_name
      string = self.dont_name.gsub(/\(.*?\)/,custom_text)
    end
    return string
  end
  
  def name_with_formatting(do_or_dont, custom_text = nil, quantity = 1, tense = :future, user = nil)
    if do_or_dont == :do
      return nil unless self.do_name.present?
      string = self.do_name.dup
    elsif do_or_dont == :dont
      if quantity.to_i > 1
        return nil unless self.do_name.present?
        string = self.do_name.dup        
      else
        return nil unless self.dont_name.present?
        string = self.dont_name.dup
      end
    else
      raise "Need to specifiy if you want the do or don't name."
    end
    
    string = Trait.substitute_determiners(string, quantity, (do_or_dont == :do ? 1 : -1), tense)
    string = self.substitute_units(string, user)

    if tense == :past and Trait::TENSES[self.verb].present?
      if do_or_dont == :dont and quantity == 1
        string = string.gsub("don't", "didn't") 
      elsif do_or_dont == :do and quantity == 0
        string = "didn't #{string}"
      else
        string = string.gsub(self.verb, Trait::TENSES[self.verb][:past])
      end
    elsif tense == :present and Trait::TENSES[self.verb].present?
      if do_or_dont == :dont and quantity == 0
        string = string.gsub("don't", "doesn't") 
      elsif do_or_dont == :do and quantity == 0
        string = "didn't #{string}"
      else
        string = string.gsub(self.verb, Trait::TENSES[self.verb][:present])
      end
    end

    if custom_text.present?
      if string.match(/\((.*)?\)/)
        match = $1
        string = string.gsub(/\(.*?\)/, custom_text).strip
      elsif string.match(/\[(.*)?\]/)
        match = $1
        string = string.gsub(/\[.*?\]/, custom_text).strip
      end   
    else
      if string.match(/\((.*)?\)/)
        match = $1
        string = string.gsub(/\(.*?\)/,"<span>#{match}</span>").strip
      elsif string.match(/\[(.*)?\]/)
        match = $1
        string = string.gsub(/\[.*?\]/,"<span>#{match}</span>").strip
      end   
    end
    return string             
  end
  
  # Name with formatting (used for the select a trait listview)
  def do_name_with_formatting(custom_text = nil, quantity = 1, tense = :future)
    string = self.name_with_formatting(:do, custom_text, quantity, tense)
    return string
  end
  def dont_name_with_formatting(custom_text = nil, quantity = 1, tense = :future)
    string = self.name_with_formatting(:dont, custom_text, quantity, tense)
    return string
  end

  # Replace #a{blah} with "a blah"
  # Do not call this outside of a instance method
  def self.substitute_determiners(string, quantity = 1, do_integer = nil, tense = :future)

    # Special traits that have the markup in it
    if string.match(/\#(a|an|any)\{(.*)?\}/)
      preposition = $1
      object = $2
      if quantity.to_f > 1 and do_integer.present?
        if do_integer == 1
          string.gsub!(/\#(a|an|any)\{(.*)?\}/, "#{quantity} #{object.pluralize}")
        elsif do_integer == -1
          string.gsub!(/\#(a|an|any)\{(.*)?\}/, "less than #{quantity} #{object.pluralize}")          
        end
      elsif quantity.to_i == 0 and tense == :present
        string = string.gsub(/(\#(a|an|any)\{(.*)?\})/,"#{object.pluralize}")        
      else 
        if preposition == 'any'
          string = string.gsub(/(\#(a|an|any)\{(.*)?\})/,"#{preposition} #{object.pluralize}")
        else
          string = string.gsub(/(\#(a|an|any)\{(.*)?\})/,"#{preposition} #{object}")          
        end
      end
      
    # If no special markup, put quantity at end of string
    elsif quantity.to_f > 1 and do_integer.present?  
      if do_integer == 1
        string += " #{quantity}"
      elsif do_integer == -1
        string += " less than #{quantity}"
      end
      string += ' #times'
    else 
      # quantity == 1 (meditated 1 minute doesn't work though... it just says "meditated")
    end
    return string    
  end
  
  def substitute_units(string, user)
    if string.match(/\#times/)
      case self.answer_type
        when ':boolean'
          string.gsub!(/\#times/, "times")
        when ':pounds'
          string.gsub!(/\#times/, "times")
        when ':miles'
          if user.present? and user.distance_units == 1
            string.gsub!(/\#times/, "kms")        
          else
            string.gsub!(/\#times/, (user ? user.distance_pref : 'mi'))
          end
        when ':minutes'
          string.gsub!(/\#times/, "mins")
        when ':seconds'
          string.gsub!(/\#times/, "secs")
        when ':steps'
          string.gsub!(/\#times/, "steps")
        when ':quantity'
          string.gsub!(/\#times/, "quantities")
        when ':time'
          string.gsub!(/\#times/, "o'clock")
        else
          string.gsub!(/\#times/, "times")
      end
    end
    return string  
  end
  
  def pluralize_nouns
    self.noun_pl = self.noun.en.plural if self.noun.present?
  end
    
  # DEPRECATED - END # 

end

# == Schema Information
#
# Table name: traits
#
#  id                 :integer(4)      not null, primary key
#  token              :string(255)
#  primary_pack_token :string(255)
#  do_name            :string(255)
#  dont_name          :string(255)
#  parent_trait_id    :integer(4)
#  setup_required     :boolean(1)      default(FALSE)
#  created_at         :datetime
#  updated_at         :datetime
#  name               :string(255)
#  verb               :string(255)
#  noun               :string(255)
#  answer_type        :string(255)
#  daily_question     :string(255)
#  noun_pl            :string(255)
#  article            :string(255)
#  past_template      :string(255)
#  hashtag            :string(255)
#

