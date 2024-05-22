# Modulofcm

Firebase Cloud Messaging client library

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add modulofcm

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install modulofcm

## Usage

```ruby
Modulofcm.configure do |config|
  config.client(:legacy_client) do |client|
    client.api_key = 'My Legacy HTTP API key - will cease to function after June 2024.'
  end

  config.client(:api_v1_client) do |client|
    client.firebase_project_id = 'Firebase Project id'
    client.google_application_credentials = '{"type": "service_account", "project_id": "...", ...}'
  end

  config.client(:another_api_v1_client) do |client|
    client.firebase_project_id = 'Firebase Project id'
    client.google_application_credentials_path = 'config/google_application_credentials.json'
  end
end

# Any data you want to add to your notification
data = {
  id: 232_342,
  key: 'asd9adfiu6bn',
  mission_id: 234_323,
  data: {
    user_id: 15_123,
    company_id: 23_341
  }
}

# All keyword arguments are optional and references a field in Firebase documentation:
# Legacy API: https://firebase.google.com/docs/cloud-messaging/http-server-ref
# APIv1 : https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages
#  title: The notification's title.
#    Legacy: `notification.title`
#    APIv1: `message.notification.title`
#  body: The notification's body text.
#    Legacy: `notification.body`
#    APIv1: `message.notification.body`,
#  sound: The sound to play when the device receives the notification.
#    Legacy: `notification.sound`
#    APIv1:
#      android: `message.android.sound`
#      ios: `message.apns.aps.sound` 
#  content_available: Allow to awaken the iOS app.
#    Legacy: `content_available` - ignored on non-iOS devices.
#    APIv1:
#      ios: `message.apns.aps.content-available`
#  data: Arbitrary key/value payload, which must be UTF-8 encoded. The key should not be a reserved word ("from", "message_type", or any word starting with "google" or "gcm").
#    Legacy: `data`
#    APIv1: `message.data`
Modulofcm.client(:legacy_client).push('Registration token', data: data, title: 'My title', body: 'The body', sound: 'notif.caf', content_available: true)
Modulofcm.client(:api_v1_client).push('Registration token', data: data, title: 'My title', body: 'The body', sound: 'notif.caf', content_available: true)
Modulofcm.client(:another_api_v1_client).push('Registration token', data: data, title: 'My title', body: 'The body', sound: 'notif.caf', content_available: true)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/modulotech/modulofcm. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/modulotech/modulofcm/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Modulofcm project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/modulotech/modulofcm/blob/master/CODE_OF_CONDUCT.md).
