require 'twilio-ruby'

# Twilio number is (206) 257-2324

# start snippet
# your Twilio authentication credentials
ACCOUNT_SID = ''
ACCOUNT_TOKEN = ''
# Outgoing Caller ID you have previously validated with Twilio
CALLER_ID = ''

# version of the Twilio REST API to use
API_VERSION = '2010-04-01'

# base URL of this application
BASE_URL = Rails.env.production? ? "http://bud.ge/twilio" : "http://budge.dev/twilio"

class TwilioApi
  def self.send_text(phone_number, message)
    return false unless phone_number.present? and phone_number.to_s != '0'
    begin
      @client = Twilio::REST::Client.new(ACCOUNT_SID, ACCOUNT_TOKEN)
      @client.account.sms.messages.create(:from => CALLER_ID,
                                          :to   => phone_number,
                                          :body => message)
    rescue => e
      p "Error sending to this number: #{phone_number}: #{e.inspect}"
      return false
    end
    return true
  end
  
  def self.robocall(phone_number, twilio_action, id = nil, id2 = nil)
    return false unless phone_number.present? and phone_number.to_s != '0'
    @client = Twilio::REST::Client.new(ACCOUNT_SID, ACCOUNT_TOKEN)
    @client.account.calls.create(:from => CALLER_ID,
                                 :to   => phone_number,
                                 :url  => "http://#{DOMAIN}/twilio/robocall/#{twilio_action}#{id.present? ? "/#{id}" : ''}#{id2.present? ? "/#{id2}" : ''}")
    return true
  end
end