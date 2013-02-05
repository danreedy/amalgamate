# a·mal·ga·mate /əˈmalgəˌmāt/

To unite together (classes, races, societies, ideas, etc.) so as to form a homogeneous or harmonious whole. (Used either of combining two elements, or one element with another.)

*Source: "amalgamate, v.". OED Online. December 2012. Oxford University Press. 5 February 2013 <http://www.oed.com/view/Entry/5975>.*

## Introduction

Amalgamate is an extension of ActiveRecord that facilitates merging two individual records into a single record. The intent is to provide a simple, fast, and safe method for reducing duplication within the database.

## Installation

### Rails 3.x

Add the following line to the project `Gemfile`

    gem 'amalgamate', '~> 0.1'

Then run `bundle install`.

## Usage

Making use of `ActiveSupport::Concern`, Amalgamate extends ActiveRecord objects to include several class methods. Refer to the documentation to see the underlining logic.

All examples will use the terms master and slave. Master being the record to keep and slave being the duplicate record.

### #unify(slave, options={})

Unify is the most frequently used method. Calling `master.unify(slave)` will:

- Fill any nil attributes of `master` with the non-nil value of the same attribute of `slave`.
- Use the attribute of `master` if there is a conflict between the same attribute of `slave`.
- Update `has_one` and `has_many` associations of `slave` to reference to `master`.
- Call `destroy` on `slave`
- Call `save` on `master` 

#### Options

| Option       | Accepted Values     | Default | Description       |
|--------------|---------------------|---------|-------------------|
| `:priority`   | `:master`, `:slave` | `:master` |Determines which object takes priority when setting attributes. If set to `:slave` the attribute values of `slave` will be used to update `master`|
| `:ignore` | `Array` of sybmols | `[:id, :created_at, :updated_at]` | Ignores attributes when merging.
| `:update_associations` | `true`, `false` | `true` | Amalgamate will update `has_one` and `has_many` associations to change `slave` associations to point to `master`|
| `:destroy` |`true`, `false` | `true` | Amalgamate will call `destroy` on `slave` after saving `master`|


### #combine(slave, options={})

Combine is a non-destructive method that results in a new instance being instantiated combining the attributes of `master` and `slave`. Calling `master.combine(slave)` will:

- Call `dup` on `master` creating a `kopy`.
- Fill any nil attributes of `kopy` with the non-nil value of the same attribute of `slave`.
- Use the attribute of `kopy` if there is a conflict between the same attribute of `slave`.
- Ignore `has_one` and `has_many` associations

Combine **does not** save the new `kopy`, save `master`, or destroy `slave`

#### Options

| Option       | Accepted Values     | Default | Description       |
|--------------|---------------------|---------|-------------------|
| `:priority`   | `:master`, `:slave` | `:master` |Determines which object takes priority when setting attributes. If set to `:slave` the attribute values of `slave` will be used to update `master`|

### #diff(slave)

Diff returns a `Hash` containing the attributes that a different between `master` and `slave`.

_Example Output_

```ruby
> master.first_name
=> "Dan"
> master.last_name
=> "Reedy"
> slave.first_name
=> "Daniel"
> slave.last_name
=> "Reedy"

> master.diff(slave)
=> { :first_name => { :master => "Dan", :slave => "Daniel" } }
```

---

This project rocks and uses MIT-LICENSE.