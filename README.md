# Switchboard

Switchboard is a Ruby on Rails application that manages text messaging communications for political and community organizers.  Switchboard is designed to be easy to use to manage text messaging announcement and discussion lists, with a goal of using a variety of low-cost messaging gateways.  

Switchboard has been developed by the [Media Mobilizing Project](http://mediamobilizingproject.org).

# Switchboard Daemon

Alongside the web application, there is a daemon that must be run alongside
the web application to process incoming and outgoing messages.

Run:

    bundle exec script/daemon start switchboard_server

To run in development mode, not daemonized, run:

    RAILS_ENV=development bundle exec script/daemon run switchboard_server

