# Pushex
[![Build Status](https://travis-ci.org/tuvistavie/pushex.svg?branch=master)](https://travis-ci.org/tuvistavie/pushex)
[![Coverage Status](https://coveralls.io/repos/github/tuvistavie/pushex/badge.svg?branch=master)](https://coveralls.io/github/tuvistavie/pushex?branch=master)


Pushex is a library to easily send push notifications with Elixir.

## About

### Goals

The main goals are the following:

  * Easy to use async API
  * Common API for iOS and Android
  * Multiple applications handling
  * Proper error and response handling
  * Testable using a sanbox mode

### Status

Both GCM and APNS are working. APNS delegates to [apns4ex](https://github.com/chvanikoff/apns4ex)
for now, I will probably use the HTTP2 API in a later version.

The API is still subject to change, with a minor version bump for each change.

## Installation

Add the following to your dependencies mix.ex.

```elixir
[{:pushex, "~> 0.1"}]
```

Then, add `:pushex` to your applications.

## Usage

The most basic usage, with no configuration looks like this:

```elixir
app = %Pushex.GCM.App{name: "a_unique_name_you_like", auth_key: "a GCM API auth key"}
Pushex.push(%{title: "my_title", body: "my_body"}, to: "registration_id", with_app: app)
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
  ],
  apns: [
    default_app: "first_app",
    apps: [
      [name: "first_app", env: :dev, certfile: "/path/to/certfile", pool_size: 5]
    ]
  ]
```

You can then do the following:


```elixir
# this will use the default app, "first_app" with the above configuration
Pushex.push(%{title: "my_title", body: "my_body"}, to: "registration_id", using: :gcm)

# this will use the other_app
Pushex.push(%{title: "my_title", body: "my_body"}, to: "registration_id", using: :gcm, with_app: "other_app")
```

Note that the function is async and only returns a reference, see the response and error
handling documentation for more information.

### Sending to multiple platforms

If you want to use the same message for both platforms, you can define messages as follow:

```elixir
message = %{
  common: "this will be in both payloads",
  other: "this will also be in both payloads",
  apns: %{
    alert: "My alert",
    badge: 1
  },
  gcm: %{
    title: "GCM title",
    body: "My body"
  }
}

Pushex.push(message, to: ["apns_token1", "apns_token2"], using: :apns)
Pushex.push(message, to: ["gcm_registration_id1", "gcm_registration_id2"], using: :gcm)
```

Only `:gcm` and `:apns` are currently available.

### Passing more options

If you need to pass options, `priority` for example, you can just pass
it in the keyword list and it will be sent.

See

https://developers.google.com/cloud-messaging/http-server-ref#downstream-http-messages-json

for more information.

The parameters from `Table 1` should be passed in the keyword list, while
the parameters from `Table 2` should be passed in the first argument.

For more information about `APNS` options, see [apns4ex](https://github.com/chvanikoff/apns4ex) docs.

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

  def find_app(platform, name) do
    if app = Repo.get_by(App, platform: platform, name: name) do
      make_app(platform, app)
    end
  end

  # transform to a `Pushex._.App`
  defp make_app(:gcm, app) do
    struct(Pushex.GCM.App, Map.from_struct(app))
  end
  defp make_app(:apns, app) do
    struct(Pushex.APNS.App, Map.from_struct(app))
  end
end
```

### Handling responses

To handle responses, you can define a module using `Pushex.EventHandler`
which uses `:gen_event` to process events.

```elixir
# config.exs
config :pushex,
  event_handlers: [MyEventHandler]

# my_event_handler.ex
defmodule MyEventHandler do
  use Pushex.EventHandler

  def handle_event({:request, request, {pid, ref}}, state) do
    # do whatever you want with the request
    # for example, logging or saving in a DB
    {:ok, state}
  end

  def handle_event({:response, response, request, {pid, ref}}, state) do
    # do whatever you want with the response and request
    {:ok, state}
  end
end
```

The `ref` passed here is the one returned when calling `push`.

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
  ref = Pushex.push(%{body: "my message"}, to: "my-user", using: :gcm)
  pid = self()
  assert_receive {{:ok, response}, request, ^ref}
  assert [{{:ok, ^response}, ^request, {^pid, ^ref}}] = Pushex.Sandbox.list_notifications
end
```

Note that `list_notifications` depends on the running process, so
if you call it from another process, you need to explicitly pass the pid with the `:pid` option.

Also note that `Pushex.push` is asynchronous, so if you
remove the `assert_receive`, you will have a race condition.
To avoid this, you can use `Pushex.Sandbox.wait_notifications/1` instead of `Pushex.Sandbox.list_notifications`.
It will wait (by default for `100ms`) until at least `:count` notifications arrive

```elixir
test "send notification to users and wait" do
  Enum.each (1..10), fn _ ->
    Pushex.push(%{body: "foo"}, to: "whoever", using: :gcm)
  end
  notifications = Pushex.Sandbox.wait_notifications(count: 10, timeout: 50)
  assert length(notifications) == 10
end
```

However, the requests are asynchronous, so there is no guaranty that the notifications
in the sandbox will in the same order they have been sent.
