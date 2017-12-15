defmodule ExIRCd do
  use Application

  def start(_type, _args) do
    port = Application.get_env(:exircd, :port)

    children = [
      {Task, fn -> IRC.Server.accept(port) end},
      {Task.Supervisor, name: IRC.ServerSupervisor}
    ]

    Supervisor.start_link(children, [restart: :permanent, strategy: :one_for_one])
  end
end
