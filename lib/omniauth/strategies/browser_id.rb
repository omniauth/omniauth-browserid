require 'omniauth'
require 'omniauth-browserid'

module OmniAuth
  module Strategies
    class BrowserID
      include OmniAuth::Strategy

      option :verify_url, 'https://browserid.org/verify'

      uid{ raw_info['email'] }

      info do
        {
          :name => raw_info['email'],
          :email => raw_info['email']
        }
      end

      def raw_info

      end
    end
  end
end
