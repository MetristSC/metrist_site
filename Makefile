
.PHONY: test deploy

test:
	npm install --prefix assets
	MIX_ENV=test mix do deps.get, test

deploy:
	#npm install --prefix assets
	MIX_ENV=prod mix do deps.get, phx.digest, release
