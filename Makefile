# For Github actions, make sure we have everything in the path even if
# we're running in a half-complete restored asdf-vm environment.
export PATH := $(PATH):$(HOME)/.asdf/shims

.PHONY: test dist deps

test: deps
	MIX_ENV=test mix test

dist: test
	npm install --prefix assets
	npm run deploy --prefix assets
	MIX_ENV=prod mix do phx.digest, release

deps:
	mix local.hex --force
	mix local.rebar --force
	mix deps.get
	docker-compose up -d
