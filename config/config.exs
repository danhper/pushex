use Mix.Config

config :pushex,
  gcm: [
    endpoint: "https://android.googleapis.com/gcm",
    client_impl: Pushex.GCM.Client.HTTP
  ]
