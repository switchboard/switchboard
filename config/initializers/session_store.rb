# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_mmp-sms_session',
  :secret      => '9fdc636f16dc48e916ad66e296f90b3ab5e0d74eba5f979e93ebdd9616ef2f043bf7cdff3646c1d0037f0d0eb8d9d07b712afd4bd67fadbbc5d8b423d2e0aafa'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
