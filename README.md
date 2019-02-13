# QuantumFields [![Build Status](https://travis-ci.com/ErvalhouS/quantum_fields.svg?branch=master)](https://travis-ci.com/ErvalhouS/quantum_fields) [![Maintainability](https://api.codeclimate.com/v1/badges/48fd7d9c967edc9327fe/maintainability)](https://codeclimate.com/github/ErvalhouS/quantum_fields/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/48fd7d9c967edc9327fe/test_coverage)](https://codeclimate.com/github/ErvalhouS/quantum_fields/test_coverage) [![Inline docs](http://inch-ci.org/github/ErvalhouS/quantum_fields.svg?branch=master)](http://inch-ci.org/github/ErvalhouS/quantum_fields)

### Give noSQL powers to your SQL database
QuantumFields is a gem to extend your Rails model's making them able to use virtual fields from a JSON column or a Text column serialized as a Hash. This means that you can use fields that were not explicitly declared in your schema as if they were.

This feature is dependent in one of two things:

  1. Your model's table should include a Hstore, JSON or JSONB column
  2. Your model's table should include a Text column that gets serialized as a Hash

You should prioritize option 1 since it translates all queries into SQL, which is great for performance. If your database does not support Hstore, JSON or JSONB you are stuck with option 2, which depends on PORO manipulation of your datasets.

## Usage
To add noSQL behavior into your model you just need to call `no_sqlize` on it.
```ruby
class MyModel < ActiveRecord::Base
  no_sqlize
end
```

This initializes the behavior on default a column called `quantum_fields`. If you wish to use another column you need declare it explicitily
```ruby
class MyModel < ActiveRecord::Base
  no_sqlize fields_column: :my_json_field
end
```

All ActiveRecord queries will now translate SQLs to QuantumFields using JSON operators, allowing you to do:
```ruby
>> MyModel.create(a_column_that_does_not_exists: 'I do exist')
# => #<Person id: 1, quantum_fields: { a_column_that_does_not_exists: 'I do exist' }>
>> MyModel.where(a_column_that_does_not_exists: 'I do exist')
# => [ #<Person id: 1, quantum_fields: { a_column_that_does_not_exists: 'I do exist' }> ]
>> MyModel.all.order(:a_column_that_does_not_exists)
# => [ #<Person id: 1, quantum_fields: { a_column_that_does_not_exists: 'I do exist' }> ]
>> MyModel.last.a_column_that_does_not_exists
# => 'I do exist'
>> MyModel.last.a_column_that_does_not_exists = "I'm here!"
# => 'I'm here!'
# And so on...
```

You can also perform per-record validations, which can get injected by a `quantum_rules` attribute. This means that if you set a record with a presence validator for a God QuantumField saving without it would raise an exception.
```ruby
>> object = MyModel.new
>> object.quantum_rules = { god: { validates: { presence: true } } }
>> object.save!
# => ActiveRecord::RecordInvalid: Validation failed: God can't be blank
```

This column is optional, but you can use any column you'd like for it by explicitily declaring in your `no_sqlize` call.
```ruby
class MyModel < ActiveRecord::Base
  no_sqlize rules_column: :my_json_field
end
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'quantum_fields'
```

And then execute:
```bash
$ bundle
```

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/ErvalhouS/quantum_fields. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant code of conduct](http://contributor-covenant.org/). To find good places to start contributing, try looking into our issue list and our Codeclimate profile.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
