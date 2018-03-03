defmodule IRC.User do
  @moduledoc """
    Процесс хранящий все данные пользователя
  """

  defstruct nick: nil, locked: false, realname: "", mode: "", registered: false, login: "", host: "127.0.0.1"

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
    nick
    |> nick_valid?
    |> case do
        true -> GenServer.call(user, {:nick, nick})
        false -> {:error, {:nickinvalid, nick}}
       end
  end

  @doc """
    Возвращает никнейм пользователя
  """
  @spec nick(pid()) :: {:ok, String.t}
  def nick(user) do
    GenServer.call(user, :get_nick)
  end

  def user(user, login, mode, realname) do
    GenServer.call(user, {:user, login, mode, realname})
  end

  @doc """
    Блокировка пользователя
  """
  @spec lock(pid()) :: :ok
  def lock(user), do: GenServer.cast(user, :lock)

  def handle_call(:get_nick, _, %User{nick: nick} = user), do: {:reply, nick, user}

  #NICK

  def handle_call({:nick, _}, _, %User{locked: true} = user) do
    {:reply, {:error, :locked}, user}
  end
  def handle_call({:nick, nick}, _from, %User{registered: true, nick: nil} = user) do
    user = %{user | nick: nick}
    {:reply, welcome_reply(user), user}
  end
  def handle_call({:nick, nick}, _from, %User{registered: false} = user) do
    {:reply, {:ok, nick}, %{user | nick: nick}}
  end
  def handle_call({:nick, nick}, _from, user) do
    {:reply, {:ok, nick}, %{user | nick: nick}}
  end

  #USER

  def handle_call({:user, _, _, _}, _from, %User{registered: true} = user) do
    {:reply, {:error, :already_registered}, user}
  end

  def handle_call({:user, login, mode, realname}, _from, %User{nick: nil} = user) do
    {
      :reply,
      :ok,
      %{user | login: login, mode: mode, realname: realname, registered: true}
    }
  end
  def handle_call({:user, login, mode, realname}, _from, user) do
    user = %{user | login: login, mode: mode, realname: realname, registered: true}
    {
      :reply,
      welcome_reply(user),
      user
    }
  end

  def handle_cast(:lock, %User{} = user), do: {:noreply, %{user | locked: true}}

  defp nick_valid?(nick) do
    Regex.match?(~r/\A[a-z_\-\[\]\\^{}|`][a-z0-9_\-\[\]\\^{}|`]{2,9}\z/i, nick)
  end

  defp welcome_reply(%User{login: login, nick: nick, host: host}) do
    {:welcome, login: login, nick: nick, host: host}
  end
end
