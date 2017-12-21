require IEx

defmodule IRC.UserRegistry do
  @moduledoc """
    Процесс хранящий всех пользователей
  """

  use GenServer

  alias IRC.User

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(server \\ __MODULE__, nick) do
    GenServer.call(server, {:lookup, nick})
  end

  def create(server \\ __MODULE__, nick) do
    GenServer.call(server, {:create, nick})
  end

  def change_nick(server \\ __MODULE__, old_nick, nick) do
    GenServer.call(server, {:change_nick, old_nick, nick})
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:lookup, nick}, _from, nicknames) do
    {:reply, Map.fetch(nicknames, nick), nicknames}
  end

  def handle_call({:change_nick, old_nick, nick}, _from, nicknames) do
    if Map.has_key?(nicknames, nick) do
      nick_in_use(nicknames, nick)
    else
      nicknames
      |> Map.fetch(old_nick)
      |> case do
          :error -> {:reply, {:error, :not_found}, nicknames}
          {:ok, user} ->
            case User.nick(user, nick) do
              {:ok, nick} ->
                nicknames = nicknames |> Map.drop([old_nick])
                {:reply, {:ok, user}, Map.put(nicknames, nick, user)}
              msg -> {:reply, msg, nicknames}
            end
        end
    end
  end

  def handle_call({:create, nick}, _from, nicknames) do
    if Map.has_key?(nicknames, nick) do
      nick_in_use(nicknames, nick)
    else
      {:ok, user} = User.start_link([])
      case User.nick(user, nick) do
        {:ok, nick} -> {:reply, {:ok, user}, Map.put(nicknames, nick, user)}
        msg -> {:reply, msg, nicknames}
      end
    end
  end

  defp nick_in_use(nicknames, nick) do
    {:reply, {:error, {:nickinuse, nick}}, nicknames}
  end
end
