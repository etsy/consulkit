# consulkit

Ruby API for interacting with HashiCorp's [Consul](https://www.consul.io/), heavily inspired by GitHub's [Octokit](https://github.com/octokit/octokit.rb).

## Installation

```
gem "consulkit"
```

## Usage

Get a client using the default options:

```ruby
client = Consulkit::Client.new
```

...or provide customized options:

```ruby
client = Consulkit.Client.new(http_addr: "https://consul.example.com", http_token: "token")
```

### KV Store

Reading keys:

```ruby
# Read a single key
client.kv_read_single("foo")
# => {"LockIndex"=>0, "Key"=>"foo", "Flags"=>1234, "Value"=>"bar", "CreateIndex"=>3532, "ModifyIndex"=>3914}

# Read key recursively
client.kv_read_recursive("foo")
# => [{"LockIndex"=>0, "Key"=>"foo", "Flags"=>1234, "Value"=>"bar", "CreateIndex"=>3532, "ModifyIndex"=>3914}, ...]

# Specify your own query parameters
client.kv_read("foo", raw: true)
# => "bar"
```

Writing keys:

```ruby
# Write a key
client.kv_write("foo", "bar", flags: 1234)
# => true

# Write a key if it doesn't exist
client.kv_write_cas("foo", "bar", 0)
=> false

> client.kv_write_cas("bar", "baz", 0)
=> true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.
