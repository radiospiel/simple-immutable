default: test rubocop

.PHONY: test rubocop release

test:
	scripts/test

rubocop:
	bin/rubocop

release:
	scripts/release.rb
