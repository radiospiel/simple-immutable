default: test

.PHONY: test

test:
	ruby test/immutable_test.rb
	bin/rubocop

release:
	scripts/release.rb
