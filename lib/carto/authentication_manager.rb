module Carto
  class AuthenticationManager
    extend ::LoggerHelper

    def self.validate_session(warden_context, request, user)
      return true if session_security_token_valid?(warden_context, user)

      request.reset_session
      false
    end

    def self.session_security_token_valid?(warden_context, user)
      log_info(message: "username #{user.username}")
      session = warden_context.session(user.username)

      log_info(message: "sec_token #{session.key?(:sec_token)}")
      return false unless session.key?(:sec_token)

      log_info(message: "session sec_token #{session[:sec_token]}")
      log_info(message: "user sec_token #{user.security_token}")
      return true if session[:sec_token] == user.security_token

      raise Carto::ExpiredSessionError.new
    rescue Warden::NotAuthenticated
      false
    end
    private_class_method :session_security_token_valid?

  end
end
