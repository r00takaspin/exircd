defmodule IRC.User do
  @moduledoc """
    Процесс хранящий все данные пользователя
  """

  defstruct nick: nil, locked: false

  @type t :: %IRC.User{nick: String.t, locked: boolean}

  use GenServer

  alias IRC.User

  @doc """
    Запуск процесса пользователя
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %User{}}
  end

  @doc """
    Задается никнейм пользователя
  """
  @type nick_invalid :: {:error, {:nickinvalid, String.t}}
  @type nick_response :: {:ok, String.t} | nick_invalid
  @spec nick(user::pid(), nick::String.t) :: nick_response
  def nick(user, nick) do
    GenServer.call(user, {:nick, nick})
  end

  @doc """
    Возвращает никнейм пользователя
  """
  @spec nick(pid()) :: {:ok, String.t}
  def nick(user) do
    GenServer.call(user, :get_nick)
  end

  @doc """
    Блокировка пользователя
  """
  @spec lock(pid()) :: :ok
  def lock(user), do: GenServer.cast(user, :lock)

  def handle_call(:get_nick, _, %User{nick: nick} = user) do
    {:reply, {:ok, nick}, user}
  end

  def handle_call({:nick, _}, _, %User{locked: true} = user) do
    {:reply, {:error, :locked}, user}
  end
  def handle_call({:nick, nick}, _from, %User{} = user) do
    nick
    |> nick_valid?
    |> case do
         true -> {:reply, {:ok, nick}, %{user | nick: nick}}
         false -> {:reply, {:error, {:nickinvalid, nick}}, user}
       end
  end

  def handle_cast(:lock, %User{} = user), do: {:noreply, %{user | locked: true}}

  defp nick_valid?(nick) do
    Regex.match?(~r/\A[a-z_\-\[\]\\^{}|`][a-z0-9_\-\[\]\\^{}|`]{2,9}\z/i, nick)
  end
end
