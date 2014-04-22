require 'rest_client'
require 'json'

module SkyscapeCF
  
  class Uaa
    def initialize(user,pass,url)
      @client = RestClient::Resource.new( url)
      
      login(user , pass)
    end
  
    def login(user,pass)
    credentials={:username => user, :password => pass}
      puts @client['oauth/authorize'].post(credentials.to_json){ |response, request, result, &block|
        if [301, 302, 307].include? response.code
          response.follow_redirection(request, result, &block)
        else
          response.return!(request, result, &block)
        end
      }
    end
    
    def authorise_token
    
    end
    
    def all
      #returns all users
    end
    
    def get_user(id)
    
    end
    
    def add_user(params)
    
    end
    
    def del_user(id)
    
    end
    
    def edit_user(id,params)
    
    end
    
    
  end
  
end
