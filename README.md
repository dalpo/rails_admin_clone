# Rails Admin Clone

Rails Admin plugin to clone existing records


## Installation

To enable rails_admin_clone, add the following to your `Gemfile`:

```ruby
gem 'rails_admin_clone'
gem 'rails_admin'
```


Add in your `config/initializers/rails_admin.rb` initializer the configuration:
```ruby
RailsAdmin.config do |config|
  config.actions do
    dashboard
    index
    new
    export
    history_index
    bulk_delete
    show
    clone   # Add the clone action
    edit
    delete
    history_show
    show_in_app
  end
end
```

## Options
You can specify a custom model method to clone objects with the following configuration:
```ruby
RailsAdmin.config do |config|
  config.model 'Team' do
    clone_config do
      custom_method :your_model_method
    end
  end
end
```

## Contributing
Submitting a Pull Request:

1. [Fork the repository.][fork]
2. [Create a topic branch.][branch]
3. Implement your feature or bug fix.
4. Add, commit, and push your changes.
5. [Submit a pull request.][pr]

[fork]: http://help.github.com/fork-a-repo/
[branch]: http://learn.github.com/p/branching.html
[pr]: http://help.github.com/send-pull-requests/


**This project rocks and uses MIT-LICENSE.**

Copyright 2013 Andrea Dal Ponte

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

