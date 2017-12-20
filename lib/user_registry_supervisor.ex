defmodule UserRegistrySupervisor do
  @moduledoc """
    Супервизор реестра пользователей
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    children = [
      UserRegistry
    ]

    supervise(children, [strategy: :one_for_one])
  end
end
