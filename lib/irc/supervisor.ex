defmodule IRC.Supervisor do
  @moduledoc """
    Корневой супервизор приложения
  """

  use Supervisor

  alias IRC.{ServerSupervisor, Server, SessionRegistry, UserRegistry}

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    port = Application.get_env(:exircd, :port)

    children = [
      {Task, fn -> Server.accept(port) end},
      {Task.Supervisor, name: ServerSupervisor},
      {UserRegistry, name: UserRegistry},
      {SessionRegistry, name: SessionRegistry}
    ]

    Supervisor.init(children, strategy: :one_for_one, restart: :permanent)
  end
end
