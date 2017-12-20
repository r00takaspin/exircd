use Mix.Config

config :exircd, port: 6667
config :pre_commit, commands: ["test", "credo", "dogma"]
