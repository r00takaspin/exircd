defmodule IRC.Commands.Nick do
  @moduledoc """
    Исполнение команды nick
  """

  alias IRC.UserRegistry

  @doc """
    Смена ника пользователя или регистрация пользователя
    с указанным никнеймом
  """
  def run(user, nick) do
    user
    |> UserRegistry.nick(nick)
    |> format_output
  end

  defp format_output({:welcome, [login: login, nick: nick, host: host]}) do
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
  defp format_output(:ok), do: :ok
  defp format_output({:ok, _}), do: :ok
  defp format_output({:error, msg}), do: format_error(msg)

  defp format_error({:invalid_params}) do
    {:error, {:ERR_NONICKNAMEGIVEN}}
  end
  defp format_error({:nick_banned, nick}) do
    {:error, {:ERR_UNAVAILRESOURCE, nick}}
  end
  defp format_error({:nickinvalid, nick}) do
    {:error, {:ERR_ERRONEUSNICKNAME, nick}}
  end
  defp format_error({:nickinuse, nick}) do
    {:error, {:ERR_NICKNAMEINUSE, nick}}
  end
end
