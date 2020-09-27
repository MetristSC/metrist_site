
.PHONY: test deploy

test: deps
	echo MIX_ENV=test mix test

dist: test
	echo npm install --prefix assets
	echo MIX_ENV=prod mix do phx.digest, release

deps:
	echo mix local.hex --force
	echo mix local.rebar --force
	echo mix deps.get
