use Mix.Config

config :ivar,
  http: [
    hackney: [ssl_options: [versions: [:'tlsv1.2']]]
  ]

import_config "#{Mix.env}.exs"
