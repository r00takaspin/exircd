defmodule IRC.Commands.Nick do
  @moduledoc """
    Исполнение команды nick
  """

  alias IRC.{UserRegistry, Session, User}

  @doc """
    Смена ника пользователя или регистрация пользователя
    с указанным никнеймом
  """
  def run(nil, _, _), do: format_error({:invalid_params})
  def run(nick, session, user_registry) do
    nick
    |> execute(session, user_registry)
    |> format_output
  end

  defp execute(nick, session, user_registry) do
    session
    |> Session.user
    |> case do
         nil ->
           register_user(user_registry, session, nick)
         user_pid ->
           {:ok, old_nick} = User.nick(user_pid)
           change_nick(user_registry, old_nick, nick)
       end
  end

  defp change_nick(user_registry, old_nick, nick) do
    user_registry
    |> UserRegistry.change_nick(old_nick, nick)
    |> case do
         {:ok, _} -> :ok
         msg -> msg
       end
  end

  defp register_user(user_registry, session, nick) do
    result = user_registry |> UserRegistry.create(nick)

    result
    |> case do
        {:ok, user} -> session |> Session.attach_user(user)
        {:error, error} -> {:error, error}
      end
  end

  def format_output(:ok), do: :ok
  def format_output({:error, msg}), do: format_error(msg)

  defp format_error({:invalid_params}) do
    {:error, {:ERR_NONICKNAMEGIVEN}}
  end
  defp format_error({:nickinvalid, nick}) do
    {:error, {:ERR_ERRONEUSNICKNAME, nick}}
  end
  defp format_error({:nickinuse, nick}) do
    {:error, {:ERR_NICKNAMEINUSE, nick}}
  end
end
