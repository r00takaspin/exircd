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

  def lookup(storage, socket) do
    GenServer.call(storage, {:lookup, socket})
  end
  def lookup(socket) do
    GenServer.call(__MODULE__, {:lookup, socket})
  end

  def create(storage \\ __MODULE__, socket) do
    GenServer.cast(storage, {:create, socket})
  end

  def handle_cast({:create, socket}, sessions) do
    if Map.fetch(sessions, socket) == :error do
      {:ok, session} = Session.start_link([])
      session |> Session.attach_socket(socket)
      {:noreply, Map.put(sessions, socket, session)}
    else
      {:noreply, sessions}
    end
  end

  def handle_call({:lookup, socket}, _from, sessions) do
    {:reply, Map.fetch(sessions, socket), sessions}
  end
end
