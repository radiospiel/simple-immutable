# rubocop:disable Metrics/AbcSize

require "test-unit"
require_relative "../lib/simple-immutable"

class Simple::Immutable::TestCase < Test::Unit::TestCase
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

  def immutable
    Immutable.create hsh
  end

  def test_hash_access
    assert_equal "a-value", immutable.a
    assert_equal "b-value", immutable.b
  end

  def test_comparison
    immutable = Immutable.create hsh

    assert_equal immutable, hsh
    assert_not_equal({}, immutable)
  end

  def test_child_access
    child = immutable.child
    assert_kind_of(Immutable, child)
    assert_equal "childname", immutable.child.name
    assert_equal "grandchildname", immutable.child.grandchild.name
  end

  def test_array_access
    assert_kind_of(Array, immutable.children)
    assert_equal 3, immutable.children.length
    assert_equal "anna", immutable.children[0]

    assert_kind_of(Immutable, immutable.children[2])
    assert_equal true, immutable.children[2].action.keep_your_mouth_shut
  end

  def test_base_class
    assert_nothing_raised do
      immutable.object_id
    end
  end

  def test_missing_keys
    assert_raise(NoMethodError) do
      immutable.foo
    end
  end

  def test_skip_when_args_or_block
    # raise NoMethodError when called with arguments
    assert_raise(NoMethodError) do
      immutable.a(1, 2, 3)
    end

    # raise NoMethodError when called with a block argument
    assert_raise(NoMethodError) do
      immutable.a { :dummy }
    end
  end

  def test_raw_data
    immutable = Immutable.create(hsh)
    expected  = hsh

    assert_equal(expected, Immutable.raw_data(immutable))
    assert_equal(expected[:children], Immutable.raw_data(immutable.children))
  end
end
