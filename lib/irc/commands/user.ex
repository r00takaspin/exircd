defmodule IRC.Commands.User do
  alias IRC.User

  @moduledoc """
    Регистрирует пользователя по юзернейму и имени и фамилии
  """

  def run(%User{pid: user}, login, mode, realname) do
    user
    |> User.user(login, mode, realname)
    |> case do
        :ok -> :ok
        {:welcome, [login: login, nick: nick, host: host]} -> format_output(:welcome, nick, login, host)
        {:error, :already_registered} -> format_output(:already_registered)
       end
  end

  defp format_output(:ok), do: :ok
  defp format_output(:already_registered), do: {:error, {:ERR_ALREADYREGISTRED}}
  defp format_output(:welcome, nick, login, host) do
    {
      :ok,
      [
        {:RPL_WELCOME, nick, login, host},
        {:RPL_YOURHOST, nick},
        {:RPL_CREATED, nick},
        {:RPL_MYINFO, nick}
      ]
    }
  end
end
