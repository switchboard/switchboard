class ProvidersController < ApplicationController
  skip_before_filter :require_user
  skip_before_filter :verify_authenticity_token

  def create
    auth = request.env['omniauth.auth']
    @was_signed_in = signed_in?
    begin
      unless @auth = Authorization.find_from_hash(auth)
        # Create a new user or add an auth to existing user, depending on
        # whether there is already a user signed in.
        @auth = Authorization.create_from_hash(auth, current_user)
        @new_auth = true
      end
      # Log the authorizing user in.
      sign_in(@auth.user, permanent: false, provider: true)
      if @was_signed_in
        redirect_to profile_path, notice: "You connected your #{Authorization::DISPLAY_NAMES[auth[:provider]]} account."
      elsif @new_auth
        redirect_back_or_default profile_path, notice: 'Your Switchboard account was created, and you are signed in.'
      else
        redirect_back_or_default root_path, notice: "You're signed in to Switchboard."
      end
    rescue Exceptions::UserExists => e
      # Attempt to create an account with an existing email address
      redirect_to signin_path, alert: 'You tried to create a new account, but there is an existing account with the same email. Did you create an account with a different service, or with an email and password?'
    end
  end

  def failure
    redirect_to root_url, alert: "An error occurred while authenticating your account"
  end
end
