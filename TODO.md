# [ ] Part one

* [x] Add Commanded
* [x] Add Überauth + Github auth via tolocalhost.com
* [x] Add Login/registration (it's the same!)
* [x] Add Account creation on registration
* [x] Add API key generation and show it
* [x] Add Ping handler with API key verification
* [x] Register agents. De-register them after 4 hours no ping. Persistent through events.
      Pings probably need to bypass the root aggregate, a separate process is probably a good idea.
      If the process times out, it can send the Node a deregister command.
      Node events (created, active, deregister) need to be handled by a registry
* [ ] Add node state to persistence and read everything on startup.
      This includes knowing when the last state change happened so we can correctly
      re-schedule timeouts (or do state changes if they already happened. But shouldn't
      we then wait a bit for agents to have a chance to check-in?
      Also, persistent state should be used when a ping is used. <== This probably first.
* [x] Show dynamic list of agents on dashboard (Registry?)
* [ ] CI and CD
      - [ ] Add Elixir runtime config for ~metrist/passwords.sh env vars
      - [ ] Wrapper script that reads ~metrist/passwords.sh (don't forget `set -e`)
      - [ ] User-level systemd config
      - [ ] Cronjob to check for a new release every minute (rotate out the old one)
* [x] Go on to agent for now

# [ ] Part two

* [ ] Receive snapshots of metrics
* [ ] Simple dashboard of snapshots
* [ ] Add live view button to graph, returns request on next ping
* [ ] Back to agent for now

# [ ] Part three

* [ ] Display live view requests by just re-routing agent data
* [ ] Figure out how to stop
* [ ] Allow monitoring code to be entered and pushed back to a selection of agents (Luerl)
* [ ] Go back to agent for now.

# [ ] Part four

* [ ] Process fetch all monitors command and return all monitors for the instance
* [ ] Go back to agent

# [ ] Part five

* [ ] Status conditions can be received and displayed on dashboard
* [ ] User can configure webhooks and emails for status conditions
* [ ] Status conditions trigger webhooks and emails.

# [ ] Odds and ends

* [ ] Show help on the site when zero agents report in, on-demand otherwise
* [ ] Actual nice upgrades. No clue how.
