class AuthenticationController < ApplicationController

  def auth_check
    ...
    if session.updated?
      auth_response = {
        updated: true,
        stytch_session: stytch_session,
        stytch_session_jwt: stytch_session_jwt,
      }
    end

    respond_to do |format|
      format.json { render json: auth_response }
    end
  end

end
