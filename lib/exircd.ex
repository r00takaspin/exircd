defmodule ExIRCd do
  use Application

  def start(_type, _args) do
    port = Application.get_env(:exircd, :port)

    children = [{Task, fn -> IRC.Server.accept(port) end}]

    opts = [strategy: :one_for_one, name: KVServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
