use Mix.Config

config :exircd, port: 6667
config :exircd, user_modes: "aiwroOs"
config :exircd, chanel_modes: "asdasdasdasd"
config :exircd, servername: "Ironclad"
config :exircd, version: "0.0.1 alpha"
config :exircd, server_created: "Sat Mar 3 2018 at 03:57:37 EDT"

config :exircd, network_adapter: IRC.NetworkAdapter

if File.exists?("config/#{Mix.env()}.exs") do
  import_config "#{Mix.env()}.exs"
end