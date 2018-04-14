defmodule IRC.Commands.Away do
  alias IRC.User

  @moduledoc """
  Исполнение команды away
  """

  @typedoc """
  Успешный выход из away
  """
  @type unaway :: {:ok, :RPL_UNAWAY}
  @spec run(user :: pid()) :: unaway
  def run(user) do
    user |> User.away
    nick = User.nick(user)

    {:ok, {:RPL_UNAWAY, nick}}
  end

  @typedoc """
  Успешная установка статуса away
  """
  @type away :: {:ok, :RPL_NOWAWAY}
  @spec run(user :: pid(), msg :: String.t) :: away
  def run(user, msg) do
    user |> User.away(msg)
    nick = User.nick(user)

    {:ok, {:RPL_NOWAWAY, nick}}
  end
end
