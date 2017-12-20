defmodule IRC.SessionRegistry do
  @moduledoc ~S"""
    Хранение сессий пользователей
  """

  use GenServer

  alias IRC.Session

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def lookup(storage, session) when is_pid(session) do
    socket = Session.socket(session)
    lookup(storage, socket)
  end
  def lookup(storage, socket) do
    GenServer.call(storage, {:lookup, socket})
  end

  def add(storage, session) do
    GenServer.cast(storage, {:create, session})
  end

  def handle_cast({:create, session}, sessions) do
    socket = Session.socket(session)
    if Map.fetch(sessions, socket) == :error do
      {:noreply, Map.put(sessions, socket, session)}
    else
      {:noreply, sessions}
    end
  end

  def handle_call({:lookup, socket}, _from, sessions) do
    {:reply, Map.fetch(sessions, socket), sessions}
  end
end
