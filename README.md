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
    imm.unknown                                 # NameError (unknown immutable attribute 'unknown')

