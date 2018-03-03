defmodule IRC.SessionRegistry do
  @moduledoc ~S"""
    Реестр сессий пользователей
  """

  use GenServer

  alias IRC.{Session, User}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{}}
  end

#  @doc """
#    Проверить наличие сокета в реестре
#  """
#  @spec lookup(pid(), port()) :: {:ok, port()} | :error
  def lookup(storage \\ __MODULE__, socket) do
    GenServer.call(storage, {:lookup, socket})
  end

#  @doc """
#    Асинхронное добавление сокета в реестр
#  """
#  @spec create(pid(), port()) :: :ok
  def create(storage \\ __MODULE__, socket) do
    GenServer.cast(storage, {:create, socket})
  end

  def handle_cast({:create, socket}, sessions) do
    if Map.fetch(sessions, socket) == :error do
      {:ok, session} = Session.start_link([])
      session |> Session.attach_socket(socket)
      {:ok, user} = User.start_link([])
      session |> Session.attach_user(user)
      {:noreply, Map.put(sessions, socket, session)}
    else
      {:noreply, sessions}
    end
  end

  def handle_call({:lookup, socket}, _from, sessions) do
    {:reply, Map.fetch(sessions, socket), sessions}
  end
end
