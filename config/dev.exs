use Mix.Config

config :pushex,
  # sandbox: true,
  gcm: [
    default_app: "default_app",
    apps: [
      [name: "default_app", auth_key: "whatever"]
    ]
  ],
  apns: [
    default_app: "default_app",
    apps: [
      [name: "default_app",
       env: :dev,
       certfile: Path.expand("../certs/debug_cert.pem", __DIR__),
       pool_size: 1]
    ]
  ]
