class SuggestionVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :suggestion
  after_save :update_counts
  
  def update_counts
    if self.suggestion.present?
      self.suggestion.update_attributes({:num_play_votes => SuggestionVote.where(:suggestion_id => self.suggestion.id, :would_play => true).size,
                                         :num_build_votes => SuggestionVote.where(:suggestion_id => self.suggestion.id, :would_build => true).size})
    end
  end
end
