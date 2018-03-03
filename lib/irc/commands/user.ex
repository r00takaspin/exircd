defmodule IRC.Commands.User do
  alias IRC.User

  @moduledoc """
    Регистрирует пользователя по юзернейму и имени и фамилии
  """

  def run(user, login, mode, realname) do
    #TODO: добавить вывод реального IP
    host = "127.0.0.1"
    nick = User.nick(user)

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
        :RPL_YOURHOST,
        :RPL_CREATED,
        :RPL_MYINFO
      ]
    }
  end
end
