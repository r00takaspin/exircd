require IEx

defmodule IRC.UserRegistry do
  @moduledoc """
    Процесс хранящий всех пользователей
  """

  defstruct nicknames: %{}, banned_nicks: []

  use GenServer

  alias IRC.{User, UserRegistry}

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

  @type pid_or_atom :: pid() | atom()
  @type nick_errors :: nick_in_use | IRC.User.nick_response
  @type nick_in_use :: {:error, {:nickinuse, String.t}}
  @type create_response :: nick_errors | {:ok, pid()}

  @spec create(registry::pid() | atom(), String.t) :: create_response
  def create(registry \\ __MODULE__, nick) do
    GenServer.call(registry, {:create, nick})
  end

  @spec change_nick(pid_or_atom(), String.t, String.t) :: create_response
  def change_nick(registry \\ __MODULE__, old_nick, nick) do
    GenServer.call(registry, {:change_nick, old_nick, nick})
  end

  @spec banned?(pid_or_atom(), nick::String.t) :: boolean
  def banned?(registry, nick) do
    GenServer.call(registry, {:is_banned, nick})
  end

  @spec ban(registy::pid(), nick::String.t) :: :ok
  def ban(registry  , nick) do
    GenServer.cast(registry, {:ban, nick})
  end

  def init(:ok) do
    {:ok, %IRC.UserRegistry{}}
  end

  def handle_call({:is_banned, nick}, _from, %UserRegistry{} = state) do
    banned_nicks = state.banned_nicks
    {:reply, Enum.member?(banned_nicks, nick), state}
  end

  def handle_call({:lookup, nick}, _from, %UserRegistry{} = state) do
    nicknames = state.nicknames
    {:reply, Map.fetch(nicknames, nick), state}
  end

  def handle_call({:change_nick, old_nick, nick}, _from, state) do
    nick(state, old_nick, nick)
  end

  def handle_call({:create, nick}, _from, state) do
    nick(state, nick)
  end

  def handle_cast({:ban, nick}, %UserRegistry{} = state) do
    {nicknames, banned_nicks} = {state.nicknames, state.banned_nicks}
    if nicknames |> _nick_exists?(nick) do
      {:ok, user_pid} = nicknames |> Map.fetch(nick)
      user_pid |> User.lock
    end

    if banned_nicks |> _banned?(nick) do
      {:noreply, state}
    else
      {:noreply, %{state | banned_nicks: banned_nicks ++ [nick]}}
    end
  end

  defp nick(%UserRegistry{} = state, nick) do
    cond do
      _nick_exists?(state.nicknames, nick) -> nick_in_use_reply(state, nick)
      _banned?(state.banned_nicks, nick) -> nick_banned_reply(state, nick)
      true -> _create_nick(state, nick)
    end
  end

  defp nick(%UserRegistry{} = state, old_nick, nick) do
    cond do
      _nick_exists?(state.nicknames, nick) -> nick_in_use_reply(state, nick)
      _banned?(state.banned_nicks, nick) -> nick_banned_reply(state, nick)
      true -> _change_nick(state, old_nick, nick)
    end
  end

  defp _create_nick(%UserRegistry{nicknames: nicknames} = state, nick) do
    {:ok, user} = User.start_link([])
    state = %{state | nicknames: nicknames |> Map.put(nick, user)}
    state |> _execute_nick(nick, user)
  end

  defp _change_nick(%UserRegistry{} = state, old_nick, nick) do
    state.nicknames
    |> Map.fetch(old_nick)
    |> case do
         :error -> {:reply, {:error, :not_found}, state}
         {:ok, user} ->
           nicknames = state.nicknames
                       |> Map.drop([old_nick])
                       |> Map.put(nick, user)
           state = %{state | nicknames: nicknames}
           state |> _execute_nick(nick, user)
       end
  end

  defp _execute_nick(state, nick, user) do
    case User.nick(user, nick) do
      {:ok, _term} -> success_reply(state, user)
      {:error, error} -> {:reply, {:error, error}, state}
    end
  end

  defp _nick_exists?(nicknames, nick), do: Map.has_key?(nicknames, nick)

  defp _banned?(banned_nicks, nick), do: Enum.member?(banned_nicks, nick)

  defp nick_in_use_reply(state, nick) do
    {:reply, {:error, {:nickinuse, nick}}, state}
  end
  defp nick_banned_reply(state, nick) do
    {:reply, {:error, {:nick_banned, nick}}, state}
  end

  defp success_reply(state, user), do: {:reply, {:ok, user}, state}
end
