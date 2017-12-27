defmodule IRC.Session do
  @moduledoc """
    Сессия пользователя
  """

  defstruct user: nil, socket: nil

  @type t :: %IRC.Session{user: pid(), socket: port()}

  use GenServer

  alias IRC.Session

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %Session{}}
  end

  @doc """
    Привязываем к сессии сокет
  """
  @spec attach_socket(pid(), port()) :: :ok
  def attach_socket(session, socket) do
    GenServer.cast(session, {:attach_socket, socket})
  end

  @doc """
    Привязываем к сессии юзера
  """
  @spec attach_user(pid(), pid()) :: :ok
  def attach_user(session, user) do
    GenServer.cast(session, {:attach_user, user})
  end

  @doc """
    Получаем PID пользователя по его сессии
  """
  @spec user(pid()) :: pid() | nil
  def user(session) do
    GenServer.call(session, :get_user)
  end

  @doc """
    Получаем TCP сокет пользователя по его сессии
  """
  @spec socket(pid()) :: port()
  def socket(session) do
    GenServer.call(session, :get_socket)
  end

  def handle_call(:get_user, _from, %Session{user: user} = session) do
    {:reply, user, session}
  end
  def handle_call(:get_socket, _from, %Session{socket: socket} = session) do
    {:reply, socket, session}
  end
  def handle_cast({:attach_socket, socket}, %Session{} = session) do
    {:noreply, %{session | socket: socket}}
  end

  def handle_cast({:attach_user, user}, %Session{} = session) do
    {:noreply, %{session | user: user}}
  end
end
