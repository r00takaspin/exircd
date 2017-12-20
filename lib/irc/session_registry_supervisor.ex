defmodule IRC.SessionRegistrySupervisor do
  @moduledoc """
    Супервизор реестра сессий
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    children = [
      IRC.SessionRegistry
    ]

    supervise(children, [strategy: :one_for_one])
  end
end
