# Pushex

Pushex is a library to easily handle mobile push notifications with Elixir.

## About

### Goals

The main goals are the following:

  * Easy to use async API
  * Common API for iOS and Android
  * Multiple applications handling
  * Proper error and response handling

### Status

The library is currently under heavy development.

The GCM part is already usable, I will be implementing the APNS part
once the API get a bit more stable.

The API is currently subject to breaking changes.

## Usage

The most basic usage, with no configuration looks like this:

```elixir
app = %Pushex.GCM.App{name: "a_unique_name_you_like", auth_key: "a GCM API auth key"}
Pushex.send_notification(%{title: "my_title", body: "my_body"}, to: "registration_id" with_app: app)
```

To avoid having to create or retreive your app each time, you can configure as many apps
as you want in your `config.exs`:

```elixir
config :pushex,
  gcm: [
    default_app: "first_app",
    apps: [
      [name: "first_app", auth_key: "a key"],
      [name: "other_app", auth_key: "another key"]
    ]
  ]
```

You can then do the following:


```elixir
# this will use the default app, "first_app" with the above configuration
Pushex.send_notification(%{title: "my_title", body: "my_body"}, to: "registration_id", using: :gcm)

# this will use the other_app
Pushex.send_notification(%{title: "my_title", body: "my_body"}, to: "registration_id", using: :gcm, with_app: "other_app")
```

Note that the function is async and only returns a reference, see the response and error
handling documentation for more information.

### Passing more options

If you need to pass options, `priority` for example, you can just pass
it in the keyword list and it will be sent to GCM (and APNS when implemented).

See

https://developers.google.com/cloud-messaging/http-server-ref#downstream-http-messages-json

for more information.

The parameters from `Table 1` should be passed in the keyword list, while
the parameters from `Table 2` should be passed in the first argument.

NOTE: if you pass an array to the `to` parameter, if will automatically
be converted to `registration_ids` when sending the request, to keep a consistent API.

### Loading app from somewhere else

If you are saving your auth_keys in your database, you can override the default way to retreive the apps:

```elixir
# config.exs
config :pushex,
  app_manager_impl: MyAppManager

# my_app_manager.ex
defmodule MyAppManager do
  @behaviour Pushex.AppManager

  def find_app(:gcm, name) do
    app = Repo.find_by(platform: gcm, name: name)
    %Pushex.GCM.App{name: name, auth_key: app.auth_key}
  end
end
```

### Handling responses

To handle responses, you can define a module implementing the `Pushex.ResponseHandler` behaviour.

```elixir
# config.exs
config :pushex,
  response_handler_impl: MyResponseHandler

# my_response_handler.ex
defmodule MyResponseHandler do
  def handle_response(response, request, {pid, ref}) do
    # do whatever you want with the response and request
    # for example, logging or saving in a DB
  end
end
```

The `ref` passed here is the one returned when calling `send_notification`.
