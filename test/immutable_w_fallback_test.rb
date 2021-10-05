# rubocop:disable Metrics/AbcSize

require "test-unit"
require_relative "../lib/simple-immutable"

class Simple::Immutable::WithFallbackTestCase < Test::Unit::TestCase
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
      "children" => [
        "anna",
        "arthur",
        {
          "action" => {
            keep_your_mouth_shut: true
          }
        }
      ]
    }
  end

  def fallback
    {
      foo: "foo-value",
      "bar" => "bar-value"
    }
  end

  def immutable
    Immutable.create hsh, fallback: fallback
  end

  def test_hash_access
    assert_equal "a-value", immutable.a
    assert_equal "b-value", immutable.b
  end

  def test_fallback_access
    assert_equal "foo-value", immutable.foo
    assert_equal "bar-value", immutable.bar
  end

  def test_missing_keys
    assert_raise(NameError) do
      immutable.unknown
    end
  end

  def test_raw_data
    # raw data does contain fallback
    expected = hsh.merge(fallback)
    assert_equal(expected, Immutable.raw_data(immutable))
  end
end
