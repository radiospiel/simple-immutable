default: test

test:
	ruby lib/simple/immutable.rb

release:
	scripts/release.rb
