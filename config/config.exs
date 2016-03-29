use Mix.Config

config :pushex,
  app_manager_impl: Pushex.AppManager.Memory,
  response_handler_impl: Pushex.ResponseHandler.Noop,
  gcm: [
    endpoint: "https://android.googleapis.com/gcm",
    client_impl: Pushex.GCM.Client.HTTP
  ]

import_config "#{Mix.env}.exs"
