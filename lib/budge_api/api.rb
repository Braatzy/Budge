require 'grape'
require 'budge_api/entities/program'
require 'budge_api/entities/user'
require 'budge_api/entities/entry'
require 'budge_api/api_key_auth'
require 'warden'

module BudgeAPI

  class API < Grape::API
    # version "v1", :using => :header

    helpers do

      def check_api_key
        #ap request
        if !BudgeAPI::ApiKeyAuth.verify_request(request)
          error!('401 Unauthorized', 401)
        end
      end

      def token_authentication
        access_token_param = params["access_token"]
        if access_token_param && access_token_param != ""
          access_token = Devise::Oauth2Providable::AccessToken.find_by_token access_token_param
          user = User.find_by_id access_token.user_id
          return user
        else
          nil
        end
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless token_authentication
      end
    end

    resource :api do

      resource :test do 
        before { authenticate! }

        get do
          "Bingo!"
        end
      end

      resource :users do
        before { authenticate! }

        get '/me' do
          user = token_authentication
          present User.find(user.id), :with => BudgeAPI::Entities::User
        end

        get '/:id' do
          present User.find(params[:id]),
                  :with => BudgeAPI::Entities::User
        end
      end

      resource :stream do
        before { authenticate! }

        get '/:page' do
          user = token_authentication

          if params[:filter] == 'everyone'
            conditions = ['privacy_setting = ? OR user_id = ?',
                          Entry::PRIVACY_PUBLIC, current_user.id]
          else
            relationship_ids  = user.relationships.select(:followed_user_id)
            followers         = relationship_ids.map{ |i| i.followed_user_id }
            conditions = ['(user_id IN (?) AND privacy_setting = ?) OR user_id = ?',
                          followers, Entry::PRIVACY_PUBLIC, user.id]
          end

          entries = Entry.paginate( :per_page => params[:per_page],
                                    :page => params[:page],
                                    :conditions => conditions,
                                    :order => 'id DESC',
                                    :include => [:user, :player_budge])

          transformed_entries = entries.map { |entry| BudgeAPI::Entities::Entry.represent entry }

          {
            :total_entries_count => entries.count, 
            :pages => (entries.count/params[:per_page].to_f).ceil,
            :page => params[:page],
            :per_page => params[:per_page],
            :entries => transformed_entries
          }
        end
      end

      resource :programs do
        # before { check_api_key }

        get do
          present Program.all, :with => BudgeAPI::Entities::Program
        end

        get '/:id' do
          present Program.find( params[:id]),
                  :with => BudgeAPI::Entities::Program
        end

        post '/:id/purchase' do
          present Program.find( params[:real_program_id]),
                  :with => BudgeAPI::Entities::Program
        end
      end
    end
  end
end
