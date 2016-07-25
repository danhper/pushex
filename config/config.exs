use Mix.Config

config :apns,
  pools: [],
  callback_module: Pushex.APNS.Callback

import_config "#{Mix.env}.exs"
