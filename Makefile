default: test rubocop

.PHONY: test rubocop release

test:
	ruby test/immutable_test.rb
	ruby test/immutable_w_null_record_test.rb

rubocop:
	bin/rubocop

release:
	scripts/release.rb
