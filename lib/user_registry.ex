defmodule UserRegistry do
  @moduledoc """
    Процесс хранящий всех пользователей
  """

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(server, nick) do
    GenServer.call(server, {:lookup, nick})
  end

  def lookup(nick) do
    GenServer.call(__MODULE__, {:lookup, nick})
  end

  def create(server, nick) do
    GenServer.call(server, {:create, nick})
  end

  def create(nick) do
    GenServer.call(__MODULE__, {:create, nick})
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:lookup, nick}, _from, nicknames) do
    {:reply, Map.fetch(nicknames, nick), nicknames}
  end

  def handle_call({:create, nick}, _from, nicknames) do
    if Map.has_key?(nicknames, nick) do
      {:noreply, nicknames}
    else
      {:ok, user} = User.start_link([])
      user
      |> User.nick(nick)
      |> case do
           {:error, error} -> {:reply, {:error, error}, nicknames}
           {:ok, nick} -> {:reply, {:ok, user}, Map.put(nicknames, nick, user)}
         end
    end
  end
end
