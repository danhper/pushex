use Mix.Config

config :pushex,
  sandbox: true,
  gcm: [
    default_app: "default_app",
    apps: [
      [name: "default_app", auth_key: "whatever"]
    ]
  ],
  apns: [
    apps: [
      [name: "default_app",
       env: :dev,
       certfile: Path.expand("../certs/debug.pem", __DIR__),
       pool_size: 5]
    ]
  ]
