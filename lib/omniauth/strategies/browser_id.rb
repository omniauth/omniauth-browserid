require 'omniauth'
require 'omniauth-browserid'
require 'faraday'
require 'multi_json'

module OmniAuth
  module Strategies
    class BrowserID
      include OmniAuth::Strategy

      option :verify_url, 'https://verifier.login.persona.org/verify'
      option :name, 'browser_id'
      option :audience_url, nil
      option :client_options, {}

      def other_phase
        if on_path?(failure_path)
          fail!('invalid_credentials')
        else
          call_app!
        end
      end

      def failure_path
        options[:failure_path] || "#{path_prefix}/redirect_failure"
      end

      def request_phase
        OmniAuth::Form.build(
          :title => "BrowserID Login",
          :url => callback_path,
          :header_info => <<-HTML
            <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js" type="text/javascript"></script>
            <script src="https://login.persona.org/include.js" type="text/javascript"></script>
            <script type='text/javascript'>
              function loginViaEmail() {
                navigator.id.get(function(assertion) {
                  if (assertion) {
                    $('input[name=assertion]').val(assertion);
                    $('form').submit();
                  } else {
                    window.location = "#{failure_path}"
                  }
                });
              }

              $(function() {
                $('button').click(function() {
                  loginViaEmail();
                  return false;
                });
              });
            </script>
          HTML
        ) do |f|
          f.html "<input type='hidden' name='assertion'/><p>Click 'Connect' to sign in with BrowserID.</p>"
        end.to_response
      end

      uid{ raw_info['email'] }
      extra{ {:raw_info => raw_info} }

      info do
        {
          :name => raw_info['email'],
          :email => raw_info['email']
        }
      end

      def raw_info
        response = connection.post('',
          :assertion => request.params['assertion'],
          :audience => full_host
        )

        MultiJson.decode(response.body)
      end

      def connection
        Faraday.new(options[:client_options].
          update(:url => options[:verify_url]))
      end
    end
  end
end
