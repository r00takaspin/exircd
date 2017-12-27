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

  @doc """
    Поиск пользователя по никнейму
  """
  @type lookup_result :: {:ok, pid()} | :error
  @spec lookup(registry::pid() | atom(), nick::String.t) :: lookup_result
  def lookup(registry \\ __MODULE__, nick) do
    GenServer.call(registry, {:lookup, nick})
  end

  @doc """
    Создаем нового пользователя с указанным никнеймом
  """

  @type nick_errors :: nick_in_use | IRC.User.nick_response
  @type nick_in_use :: {:error, {:nickinuse, Strint.t}}
  @type create_response :: nick_errors | {:ok, pid()}

  @spec create(registry::pid() | atom(), String.t) :: create_response
  def create(registry \\ __MODULE__, nick) do
    GenServer.call(registry, {:create, nick})
  end

  @spec change_nick(registry::pid() | atom(), String.t, String.t) :: nick_errors
  def change_nick(registry \\ __MODULE__, old_nick, nick) do
    GenServer.call(registry, {:change_nick, old_nick, nick})
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
      user
      |> User.nick(nick)
      |> case do
        {:ok, nick} -> {:reply, {:ok, user}, Map.put(nicknames, nick, user)}
        {:error, error} -> {:reply, {:error, error}, nicknames}
      end
    end
  end

  defp nick_in_use(nicknames, nick) do
    {:reply, {:error, {:nickinuse, nick}}, nicknames}
  end
end
