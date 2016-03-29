use Mix.Config

config :pushex,
  response_handler_impl: Pushex.DummyHandler,
  gcm: [
    client_impl: Pushex.GCM.Client.Sandbox,
    default_app: "default_app",
    apps: [
      [name: "default_app", auth_key: "whatever"]
    ]
  ]
