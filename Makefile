
.PHONY: test deploy

test: deps
	npm install --prefix assets
	MIX_ENV=test mix test

dist: test
	npm install --prefix assets
	MIX_ENV=prod mix do phx.digest, release

deps:
	mix local.hex --force
	mix local.rebar --force
	mix deps.get
