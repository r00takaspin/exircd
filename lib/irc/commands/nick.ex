require IEx

defmodule IRC.Commands.Nick do
  @moduledoc """
    Исполнение команды nick
  """

  alias IRC.{UserRegistry, Session, User}

  @doc """
    Смена ника пользователя или регистрация пользователя
    с указанным никнеймом
  """
  def run(nil, _, _), do: {:error, {:ERR_NONICKNAMEGIVEN}}
  def run(nick, session, user_registry) do
    nick
    |> execute(session, user_registry)
    |> format_output
  end

  defp execute(nick, session, user_registry) do
    user = session |> Session.user

    if is_pid(user) do
      {:ok, old_nick} = User.nick(user)
      user_registry |> UserRegistry.change_nick(old_nick, nick)
    else
      result = UserRegistry.create(user_registry, nick)
      case result do
        {:ok, user} -> session |> Session.attach_user(user)
        msg -> msg
      end
    end
  end

  def format_output(:ok), do: :ok
  def format_output({:ok, _}), do: :ok
  def format_output({:error, msg}), do: format_error(msg)

  defp format_error({:nickinvalid, nick}) do
    {:error, {:ERR_ERRONEUSNICKNAME, nick}}
  end
  defp format_error({:nickinuse, nick}) do
    {:error, {:ERR_NICKNAMEINUSE, nick}}
  end
end
