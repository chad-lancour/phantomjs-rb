# phantomjs-rb

A ruby wrapper for phantomjs and casperjs.

## Requirements

You have to have `phantomjs` installed.

## Add to Gemfile

```rb
gem 'phantomjs-rb', git: 'https://github.com/chad-lancour/phantomjs-rb.git'
```

## Configuring the path to phantomjs

If you are using phantomjs in a non-typical installation path or are including the
binary inside your application, you can configure phantomjs-rb to use a custom path.

If you are using casperjs, it requires phantomjs be on the path and named phantomjs.

The following example is a good starting point for phantomjs:
```rb
osx = Rails.env.development? || Rails.env.test?
Phantomjs.configure do |config|
  config.phantomjs_path = "#{Rails.root}/bin/phantomjs-#{osx ? 'osx' : 'x86'}"
end
```

The following example is a good starting point for casperjs:
```rb
Phantomjs.configure do |config|
  # execute casperjs, which executes phantomjs
  config.phantomjs_path = "#{BASE_PATH}/bin/casperjs"
  # only needed if phantom is not already on the PATH
  config.phantomjs_env_path = { "PATH" => "#{BASE_PATH}/bin:#{ENV['PATH']}" }
  # only used when using string scripts via inline. Allows overriding default of Dir.tmpdir
  config.phantomjs_tmpdir = "#{BASE_PATH}/tmp"
end
```

## Usage

### Pass a file

Use `Phantomjs.run` to run the passed script file.

```js
// my_runner.js
var arg1 = phantom.args[0];
var arg2 = phantom.args[1];
console.log(arg1 + ' ' + arg2);
```

Then in ruby:

```rb
Phantomjs.run('my_runner.js', 'hello', 'world')
#=> 'hello world'
```

### Pass a script

You can also pass a javascript string as an argument and call
`Phantomjs.inline`. This will create a temporary file for it
and run the script.

NOTE: Just don't forget to call `phantom.exit`.

```rb
js = <<JS
  console.log(phantom.args[0] + ' ' + phantom.args[1]);
  phantom.exit();
JS

Phantomjs.inline(js, 'hello', 'world')
#=> 'hello world'
```

### But what about async scripts?

Well it works for that too! Just pass a `block` to the method call and the
argument will be whatever your script puts out on `stdout`.

```rb
js = <<JS
  ctr = 0;
  setInterval(function() {
    console.log('ctr is: ' + ctr);
    ctr++;

    if (ctr == 3) {
      phantom.exit();
    }
  }, 5000);
JS

Phantomjs.inline(js) do |line|
  p line
end
#=> ctr is: 0
    ctr is: 1
    ctr is: 2
```

## Running the tests

```
bundle exec rake spec
```

## License

MIT
