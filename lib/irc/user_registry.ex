defmodule IRC.UserRegistry do
  @moduledoc """
  Интерфейс к реестру юзеров
  """

  alias IRC.{User}

  @network_adapter Application.get_env(:exircd, :network_adapter)
  @server_host Application.get_env(:exircd, :serverhost)
  @registry UserRegistry

  def reset_meta() do
    Registry.put_meta(@registry, :banned_nicknames, [])
  end

  @doc """
  Нахождение существующего или инициализация нового пользователя по сокету
  """
  def find_or_create_by_socket(socket) do
    host = @network_adapter.get_ip(socket)

    case lookup(socket) do
      false -> User.start_link(socket, host)
      msg -> msg
    end
  end

  def get(target) do
    case get_nick(target) do
      {:error, msg} -> {:error, msg}
      nick ->
        case lookup(nick) do
          false -> {:error, {:ERR_NOSUCHNICK, target}}
          {:ok, target_pid} -> target_pid
        end
    end
  end

  @doc """
    Поиск пользователя по никнейму/сокету
  """
  def lookup(key) do
    case Registry.lookup(@registry, key) do
      [] -> false
      [{pid, _} |_] -> {:ok, pid}
    end
  end

  @doc """
    Задаем или изменяем пользователю имя
  """
  def nick(user, nick) do
    cond do
      nick_exists?(user, nick) -> nick_in_use_reply(nick)
      banned?(nick) -> nick_banned_reply(nick)
      true -> execute_nick(user, nick)
    end
  end

  @doc """
  Является ли пользователь с никнеймом забаненым
  """
  def banned?(nick) do
    banned = banned_nicknames()
    Enum.member?(banned, nick)
  end

  @spec ban(nick::String.t) :: :ok
  def ban(nick) do
    banned = banned_nicknames()
    unless Enum.member?(banned, nick) do
      Registry.put_meta(@registry, :banned_nicknames, banned ++ [nick])
    end
    :ok
  end

  defp execute_nick(user, nick) do
    case User.nick(user, nick) do
      {:ok, _term} -> success_reply(user)
      {:error, error} -> {:error, error}
      {:welcome, msg} -> {:welcome, msg}
    end
  end

  defp nick_exists?(user, nick) do
    result = lookup(nick)
    result && result != user
  end

  defp banned_nicknames do
    case Registry.meta(@registry, :banned_nicknames) do
      :error ->
        Registry.put_meta(@registry, :banned_nicknames, [])
        []
      {:ok, nicknames} -> nicknames
    end
  end

  defp nick_in_use_reply(nick) do
    {:error, {:nickinuse, nick}}
  end

  defp nick_banned_reply(nick) do
    {:error, {:nick_banned, nick}}
  end

  defp success_reply(user), do: {:ok, user}

  defp get_nick(username) do
    case String.split(username, "@") do
      [^username] -> username
      [username, @server_host] -> username
      [_username, servername] -> {:error, {:ERR_NOSUCHSERVER, servername}}
    end
  end
end
