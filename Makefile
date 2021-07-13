default: test

.PHONY: test

test:
	ruby test/immutable_test.rb
	ruby test/immutable_w_null_record_test.rb
	bin/rubocop

release:
	scripts/release.rb
