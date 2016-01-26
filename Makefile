.PHONY: test-install test

test-install:
	npm install moment@2.8.2 moment-timezone@0.2.1 mocha@2 should@8 coffee-script@1

test:
	TZ=GMT ./node_modules/.bin/mocha --compilers coffee:coffee-script/register --slow 2 Moment.test.coffee
