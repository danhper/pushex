# Pushex
[![Build Status](https://travis-ci.org/tuvistavie/pushex.svg?branch=master)](https://travis-ci.org/tuvistavie/pushex)
[![Coverage Status](https://coveralls.io/repos/github/tuvistavie/pushex/badge.svg?branch=master)](https://coveralls.io/github/tuvistavie/pushex?branch=master)


Pushex is a library to easily send mobile push notifications with Elixir.

## About

### Goals

The main goals are the following:

  * Easy to use async API
  * Common API for iOS and Android
  * Multiple applications handling
  * Proper error and response handling
  * Easy to test

### Status

The library is currently under heavy development.

The GCM part is already usable, I will be implementing the APNS part
once the API get a bit more stable.

The API is currently subject to breaking changes.

## Installation

Add the following to your dependencies mix.ex.

```
[{:vex, github: "tuvistavie/vex", branch: "add-type-validator"},
 {:pushex, "~> 0.0.1"}]
```

The first one is temporary the time we get on an agreement on

https://github.com/CargoSense/vex/pull/24

Then, add `:pushex` to your applications.


## Usage

The most basic usage, with no configuration looks like this:

```elixir
app = %Pushex.GCM.App{name: "a_unique_name_you_like", auth_key: "a GCM API auth key"}
Pushex.send_notification(%{title: "my_title", body: "my_body"}, to: "registration_id", with_app: app)
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
    if app = Repo.get_by(App, platform: "gcm", name: name) do
      %Pushex.GCM.App{name: name, auth_key: app.auth_key}
    end
  end
end
```

### Handling responses

To handle responses, you can define a module implementing the `Pushex.ResponseHandler` behaviour.

```elixir
# config.exs
config :pushex,
  response_handlers: [MyResponseHandler]

# my_response_handler.ex
defmodule MyResponseHandler do
  def handle_response(response, request, {pid, ref}) do
    # do whatever you want with the response and request
    # for example, logging or saving in a DB
  end
end
```

The `ref` passed here is the one returned when calling `send_notification`.

## Testing

Pushex offers a sandbox mode to make testing easier.

To enable it, you should add the following to your configuration:

```
config :pushex,
  sandbox: true
```

Once you are using the sandbox, the messages will not be sent to GCM or APNS anymore,
but stored in `Pushex.Sandbox`. Furthermore, all the messages will be returned
to the process that sent them.
Here is a sample test.

```elixir
test "send notification to users" do
  ref = Pushex.send_notification(%{body: "my message"}, to: "my-user", using: :gcm)
  pid = self()
  assert_receive {{:ok, response}, request, ^ref}
  assert [{{:ok, ^response}, ^request, {^pid, ^ref}}] = Pushex.Sandbox.list_notifications
end
```

Note that `list_notifications` depends on the running process, so
if you call it from another process, you need to explicitly pass the pid with the `:pid` option.

Also note that `Pushex.send_notification` is asynchronous, so if you
remove the `assert_receive`, you will have a race condition.
To avoid this, you can use `Pushex.wait_notifications/1` instead of `Pushex.list_notifications`.
It will wait (by default for `100ms`) until at least `:count` notifications arrive

```elixir
test "send notification to users and wait" do
  Enum.each (1..10), fn _ ->
    Helpers.send_notification(%{body: "foo"}, to: "whoever", using: :gcm)
  end
  notifications = Pushex.Sandbox.wait_notifications(count: 10, timeout: 50)
  assert length(notifications) == 10
end
```

However, the requests are asynchronous, so there is no guaranty that the notifications
in the sandbox will in the same order they have been sent.
