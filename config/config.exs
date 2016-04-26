use Mix.Config

config :vex,
  sources: [Pushex.Validators, Vex.Validators]

import_config "#{Mix.env}.exs"
