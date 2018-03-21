defmodule IRC.Commands.Nick do
  @moduledoc """
    Исполнение команды nick
  """

  alias IRC.{UserRegistry, Session, User}

  @doc """
    Смена ника пользователя или регистрация пользователя
    с указанным никнеймом
  """
  def run(nick, session, user_registry) do
    nick
    |> execute(session, user_registry)
    |> format_output
  end

  defp execute(nick, session, user_registry) do
    user = session |> Session.user

    user
    |> User.nick
    |> case do
         nil ->
           user_registry
           |> UserRegistry.create(nick, user)
         old_nick ->
           user_registry
           |> change_nick(old_nick, nick, user)
       end
  end

  defp change_nick(user_registry, old_nick, nick, user) do
    user_registry
    |> UserRegistry.change_nick(old_nick, nick)
    |> case do
         {:ok, _} -> :ok
         msg -> msg
       end
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
