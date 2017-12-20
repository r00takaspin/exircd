defmodule ExIRCd do
  @moduledoc """
    Реализация IRC сервера
  """

  use Application

  def start(_type, _args) do
    IRC.Supervisor.start_link([])
  end
end
