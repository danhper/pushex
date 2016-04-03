use Mix.Config

config :pushex,
  sandbox: true,
  gcm: [
    default_app: "default_app",
    apps: [
      [name: "default_app", auth_key: "whatever"]
    ]
  ]
