# rubocop:disable Metrics/AbcSize

require "test-unit"
require_relative "../lib/simple-immutable"

class Simple::Immutable::WithNullRecordTestCase < Test::Unit::TestCase
  Immutable = ::Simple::Immutable

  def hsh
    {
      a: "a-value",
      "b": "b-value",
      "child": {
        name: "childname",
        grandchild: {
          name: "grandchildname"
        }
      },
      "children": [
        "anna",
        "arthur",
        {
          action: {
            keep_your_mouth_shut: true
          }
        }
      ]
    }
  end

  def null_record
    {
      foo: "foo-value",
      "bar" => "bar-value"
    }
  end

  def immutable
    Immutable.create hsh, null_record: null_record
  end

  def test_hash_access
    assert_equal "a-value", immutable.a
    assert_equal "b-value", immutable.b
  end

  def test_null_record_access
    assert_equal "foo-value", immutable.foo
    assert_equal "bar-value", immutable.bar
  end

  def test_missing_keys
    assert_raise(NoMethodError) do
      immutable.unknown
    end
  end

  def test_raw_data
    # raw data does contain null_record
    expected = hsh.merge(null_record)
    assert_equal(expected, Immutable.raw_data(immutable))
  end
end
