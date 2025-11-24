# Ruby ChatKit

A Ruby client library for OpenAI's ChatKit API, providing easy-to-use interfaces for creating sessions, sending messages, and uploading files.

## Features

- 🔐 Session management with automatic refresh
- 💬 Send text messages to ChatKit conversations
- 📎 File upload support with message attachments
- 🔄 Streaming response parsing
- ⚡ Built-in error handling

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby-chatkit'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install ruby-chatkit
```

## Usage

### Configuration

Configure the gem with your OpenAI API key:

```ruby
ChatKit.configure do |config|
  config.api_key = "sk-proj-your-api-key-here"
end
```

You can also set the API key using an environment variable:

```bash
export OPENAI_API_KEY="sk-proj-your-api-key-here"
```

### Quick Start

```ruby
# Initialize the client
client = ChatKit::Client.new

# Create a session
client.create_session!(
  user_id: "user_123",
  workflow_id: "wf_your_workflow_id"
)

# Send a message
response = client.send_message!(text: "Hello, how are you?")
puts response.text
```

### Sending Messages with File Attachments

```ruby
# Open a file
file = File.open("/path/to/your/image.png")

# Send message with attachment
response = client.send_message!(
  text: "Could you describe this image?",
  files: [file]
)

puts response.text
```

### Advanced Session Configuration

```ruby
client.create_session!(
  user_id: "user_123",
  workflow_id: "wf_your_workflow_id",
  chatkit_configuration: {
    history: { enabled: true },
    file_upload: { enabled: true },
    automatic_thread_titling: { enabled: true }
  },
  expires_after: {
    anchor: "creation",
    seconds: 3600
  },
  rate_limits: {
    max_requests_per_1_minute: 100
  }
)
```

### Manual Session and Conversation Management

For more control, you can use the underlying classes directly:

```ruby
# Create a session manually
session = ChatKit::Session.create!(
  user_id: "user_123",
  workflow: { id: "wf_your_workflow_id" },
  client: client
)

# Send a conversation message
conversation = ChatKit::Conversation.send_message!(
  client_secret: session.response.client_secret,
  text: "Hello!",
  client: client
)

# Access the response
answer = conversation.response.answer
puts answer.text
```

### File Upload

Upload files to ChatKit:

```ruby
file = File.open("/path/to/document.pdf")

response = ChatKit::Files.upload!(
  client_secret: session.response.client_secret,
  file: file,
  client: client
)

puts response.id
puts response.name
puts response.mime_type
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/saleszera/ruby-chatkit. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/ruby-chatkit/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ruby::Chatkit project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ruby-chatkit/blob/main/CODE_OF_CONDUCT.md).
