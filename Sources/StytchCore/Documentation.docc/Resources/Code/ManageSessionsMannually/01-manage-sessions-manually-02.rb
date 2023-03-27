class AuthenticationController < ApplicationController

  def auth_check
    # ...
    response.set_header('stytch_session', stytch_token)
    response.set_header('stytch_session_jwt', stytch_jwt)

    respond_to do |format|
      format.json { render json: some_response }
    end
  end

end
