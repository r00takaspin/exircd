defmodule IRC.User do
  @moduledoc """
    Процесс хранящий все данные пользователя
  """

  defstruct nick: nil,
            locked: false,
            realname: "",
            mode: "",
            registered: false,
            login: "",
            host: "127.0.0.1",
            socket: nil

  @type t :: %IRC.User{nick: String.t, locked: boolean}

  use GenServer

  alias IRC.User

  @doc """
    Запуск процесса пользователя
  """
  def start_link(socket) do
    name = via_tuple(socket)
    GenServer.start_link(__MODULE__, socket, name: name)
  end

  defp via_tuple(socket) do
    {:via, Registry, {UserRegistry, socket}}
  end

  def init(socket) do
    {:ok, %User{socket: socket}}
  end

  @doc """
  Получаем параметр пользователя по его PID
  """
  def get_param(user, param), do: GenServer.call(user, {:get_param, param})

  @doc """
    Задается никнейм пользователя
  """
  @spec nick(user::pid(), nick::String.t) :: term()
  def nick(user, nick) do
    nick
    |> nick_valid?
    |> case do
        true -> GenServer.call(user, {:nick, nick})
        false -> {:error, {:nickinvalid, nick}}
       end
  end

  def quit(user) do
    GenServer.stop(user)
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

  def handle_call({:get_param, param}, _, user), do: {:reply, Map.get(user, param), user}

  def handle_call(:get_nick, _, %User{nick: nick} = user), do: {:reply, nick, user}

  #NICK

  def handle_call({:nick, _}, _, %User{locked: true} = user) do
    {:reply, {:error, :locked}, user}
  end
  def handle_call({:nick, nick}, _from, %User{registered: true, nick: nil} = user) do
    register_nick(nick)
    user = %{user | nick: nick}
    {:reply, welcome_reply(user), user}
  end
  def handle_call({:nick, nick}, _from, %User{registered: false, nick: old_nick} = user) do
    register_nick(nick)
    unregister_nick(old_nick)
    {:reply, {:ok, nick}, %{user | nick: nick}}
  end
  def handle_call({:nick, nick}, _from, %User{nick: old_nick} = user) do
    register_nick(nick)
    unregister_nick(old_nick)
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

  defp register_nick(nick) do
    Registry.register(UserRegistry, nick, self())
  end

  defp unregister_nick(nick) do
    Registry.unregister(UserRegistry, nick)
  end
end
