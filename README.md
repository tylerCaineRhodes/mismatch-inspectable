The `MismatchInspectable` module provides a way to compare two objects and find the differences in their attributes. The module can be included in any class to compare objects of that class, and it provides options for the output format, recursion, and inclusion of class names in the output.


- [Usage](#usage)
- [Options](#options)
  - [format](#format)
  - [include\_class (default: true)](#include_class-default-true)
  - [recursive (default: false)](#recursive-default-false)
- [Examples](#examples)
  - [Example 1: Basic usage](#example-1-basic-usage)
  - [Example 2: Using different formats](#example-2-using-different-formats)
  - [Example 3: Comparing nested objects](#example-3-comparing-nested-objects)
  - [Example 4: Excluding class from output](#example-4-excluding-class-from-output)
  - [Example 5: Comparing objects with recursive set to false](#example-5-comparing-objects-with-recursive-set-to-false)
  - [Example 6: Comparing objects when one is null](#example-6-comparing-objects-when-one-is-null)

***
## Usage

To use `MismatchInspectable`, first include it in your class and list the attributes you want to compare using the `inspect_mismatch_for` method.

 ```ruby
class Thing
  include MismatchInspectable

  inspect_mismatch_for :color, :shape, :is_cool

  def initialize(color, shape, is_cool)
    @color = color
    @shape = shape
    @is_cool = is_cool
  end

  # Your class implementation
end
```

Then, to compare two objects of the class, call the inspect_mismatch method on one of the objects and pass the other object as an argument.

```ruby
thing1 = Thing.new("red", "circle", true)
thing2 = Thing.new("blue", "circle", false)

mismatch = thing1.inspect_mismatch(thing2)
```

***
## Options

### format
You can choose from three different output formats: :array, :hash, or :object. The default format is :array.


• :array format example:

```ruby
[
  ['Thing#color', 'red', 'blue'],
  ['Thing#is_cool', true, false]
]
```

• :hash format example:
```ruby
{
  'Thing#color' => ['red', 'blue'],
  'Thing#is_cool' => [true, false]
}
```

:object format example:
```ruby
{
  Thing: {
    color: ['red', 'blue'],
    is_cool: [true, false]
  }
}
```

### include_class (default: true)

 When this option is set to true, the comparison will include the class in the
 output for the objects being compared. If the objects being compared have
 different classes, a mismatch will always be reported, regardless of this flag
 being set. If set to false, you will simply not see the class names in the
 output.


### recursive (default: false)
When this option is set to true, the comparison will be performed recursively on
all instance variables which are passed to `inspect_mismatch_for`. If any of the
instance variables are also objects that include the `MismatchInspectable`
module, their `inspect_mismatch` method will be called with the same options. If
set to false,the comparison will only be performed on the top-level instance
variables which are passed to `inspect_mismatch_for` and will not delve deeper
into the objects.  Instead it will do a simple comparison of said instance
variables.

***
## Examples
### Example 1: Basic usage

```ruby
require "mismatch_inspectable"

class Car
  include MismatchInspectable

  inspect_mismatch_for :make, :model, :year

  def initialize(make, model, year)
    @make = make
    @model = model
    @year = year
  end

  attr_accessor :make, :model, :year
end

car1 = Car.new("Toyota", "Camry", 2020)
car2 = Car.new("Toyota", "Corolla", 2020)
mismatches = car1.inspect_mismatch(car2)

# Output with default format: array
# [["Car#model", "Camry", "Corolla"]]
```


### Example 2: Using different formats

```ruby
mismatches_hash = car1.inspect_mismatch(car2, format: :hash)

# Output with format: hash
# {"Car#model" => ["Camry", "Corolla"]}

mismatches_object = car1.inspect_mismatch(car2, format: :object)

# Output with format: object
# {Car: {model: ["Camry", "Corolla"]}}
```

### Example 3: Comparing nested objects

```ruby
class Owner
  include MismatchInspectable

  inspect_mismatch_for :name, :age

  def initialize(name, age)
    @name = name
    @age = age
  end

  attr_accessor :name, :age
end

class Pet
  include MismatchInspectable

  inspect_mismatch_for :name, :species, :owner

  def initialize(name, species, owner)
    @name = name
    @species = species
    @owner = owner
  end

  attr_accessor :name, :species, :owner
end

owner1 = Owner.new("Alice", 30)
owner2 = Owner.new("Bob", 35)
pet1 = Pet.new("Fluffy", "cat", owner1)
pet2 = Pet.new("Fluffy", "cat", owner2)

mismatches = pet1.inspect_mismatch(pet2, recursive: true)

# Output with recursive: true
# [["Pet#owner.Owner#name", "Alice", "Bob"], ["Pet#owner.Owner#age", 30, 35]]
```


### Example 4: Excluding class from output
```ruby
mismatches_no_class = pet1.inspect_mismatch(pet2, recursive: true, include_class: false)

# Output with include_class: false
# [["owner.name", "Alice", "Bob"], ["owner.age", 30, 35]]
```

### Example 5: Comparing objects with recursive set to false

```ruby
pet5 = Pet.new("Max", "dog", owner1)
pet6 = Pet.new("Max", "dog", owner2)

mismatches_non_recursive = pet5.inspect_mismatch(pet6, recursive: false)

# Output with recursive: false and non-nil owners
# [["Pet#owner", #<Owner:0x00007fe3d206d3c8 @name="Alice", @age=30>, #<Owner:0x00007fe3d207d3c8 @name="Bob", @age=35>]]
```

### Example 6: Comparing objects when one is null

```ruby
owner3 = Owner.new("Charlie", 40)
pet3 = Pet.new("Buddy", "dog", owner3)
pet4 = Pet.new("Buddy", "dog", nil)

mismatches_owner_nil = pet3.inspect_mismatch(pet4, recursive: true)

# Output with recursive: true and one nil owner
# [["Pet#owner", #<Owner:0x00007fe3d206d3c8 @name="Charlie", @age=40>, nil]]
```