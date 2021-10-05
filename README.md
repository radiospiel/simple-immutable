# simple-immutable

Turns a nested data structure into a immutable ruby object implementing dot and [] accessors.

## Usage


    Immutable = ::Simple::Immutable

    data =
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
      
    imm = Immutable.create(data)
    
    imm.a # -> 'a-value'
    imm.children.class                          # -> Array
    imm.children[2].action.keep_your_mouth_shut # -> true
    imm.children.foo                            # NoMethodError (undefined method `foo' for #<Array:0x00007fb90f1be390>)
    imm.children.first.foo                      # NoMethodError (undefined method `foo' for "anna":String)

If an attribute is not defined in the immutable (or in any sub-immutable) we raise a NameError

    imm.unknown                                 # NameError (unknown immutable attribute 'unknown')

One can check for an attribute by appending a "?". If the attribute is not defined this returns +nil+ instead of raising an error.

    imm.a?                                      # 'a-value'
    imm.unknown?                                # nil
    imm.foo?.bar?                               # also nil

When building an immutable one can provide a "fallback" hash in addition to the returned hash. If a key does not exist in the passed in data it will be fetched from the "fallback" data. This is rarely useful, but can provide effectove optimization in some cases.
