class AuthenticationController < ApplicationController

  def auth_check
    ...
    if session.updated?
      cookies[:stytch_session] = {
        value: stytch_token,
        expires: session.expires_at,
        domain: 'mybackend.com',
      }
      cookies[:stytch_session] = {
        value: stytch_jwt,
        expires: session.expires_at,
        domain: 'mybackend.com',
      }
      auth_response = { updated: true }
    end

    respond_to do |format|
      format.json { render json: auth_response }
    end
  end

end
