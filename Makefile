default: test

test:
	ruby lib/simple/immutable.rb
	bin/rubocop

release:
	scripts/release.rb
