defmodule IRC.Commands.Away do
  alias IRC.{User, UserRegistry}

  @moduledoc """
  Исполнение команды away
  """

  @typedoc """
  Успешный выход из away
  """
  @type unaway :: {:ok, :RPL_UNAWAY}
  @spec run(user :: pid()) :: unaway
  def run(%User{pid: user, nick: nick}) do
    user |> User.away

    {:ok, {:RPL_UNAWAY, nick}}
  end

  @typedoc """
  Успешная установка статуса away
  """
  @type away :: {:ok, :RPL_NOWAWAY}
  @spec run(user :: pid(), msg :: String.t) :: away
  def run(%User{pid: user, nick: nick}, msg) do
    user |> User.away(msg)

    {:ok, {:RPL_NOWAWAY, nick}}
  end
end
