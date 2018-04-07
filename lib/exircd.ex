defmodule ExIRCd do
  @moduledoc """
    Реализация IRC сервера
  """

  use Application

  def start(_type, [port: port]) do
    IRC.Supervisor.start_link(port)
  end

  def start(_type, _args) do
    port = Application.get_env(:exircd, :port)

    IRC.Supervisor.start_link(port)
  end
end
