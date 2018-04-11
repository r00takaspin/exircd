defmodule IRC.Supervisor do
  @moduledoc """
    Корневой супервизор приложения
  """

  use Supervisor

  alias IRC.{ServerSupervisor, Server}

  def start_link(port) do
    Supervisor.start_link(__MODULE__, port, [])
  end

  def init(port) do
    children = [
      {Task, fn -> Server.accept(port) end},
      {Task.Supervisor, name: ServerSupervisor},
      {Registry, [keys: :unique, name: UserRegistry]},
    ]

    Supervisor.init(children, strategy: :one_for_one, restart: :permanent)
  end
end
