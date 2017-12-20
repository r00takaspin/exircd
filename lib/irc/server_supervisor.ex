defmodule IRC.ServerSupervisor do
  @moduledoc """
    Супервизор TCP сервера
  """

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      IRC.Server, name: IRC.Server,
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
