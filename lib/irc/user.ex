defmodule IRC.User do
  @moduledoc """
    Процесс хранящий все данные пользователя
  """

  use GenServer

  alias IRC.{User, Reply}

  @server_name Application.get_env(:exircd, :servername)

  defstruct nick: nil,
            locked: false,
            login: nil,
            realname: nil,
            mode: "",
            host: nil,
            socket: nil,
            registered?: false

  @doc """
    Запуск процесса пользователя
  """
  def start_link(socket, host) do
    name = via_tuple(socket)
    GenServer.start_link(__MODULE__, [socket, host], name: name)
  end

  defp via_tuple(socket) do
    {:via, Registry, {UserRegistry, socket}}
  end

  def init([socket, host]) do
    {:ok, %User{socket: socket, host: host}}
  end

  @doc """
  Получаем параметр пользователя по его PID
  """
  def get_param(user, param), do: GenServer.call(user, {:get_param, param})

  @doc """
    Задается никнейм пользователя
  """
  @spec nick(user :: pid(), nick :: String.t()) :: term()
  def nick(user, nick) do
    nick
    |> nick_valid?
    |> case do
      true -> GenServer.call(user, {:nick, nick})
      false -> {:error, {:nickinvalid, nick}}
    end
  end

  @doc """
    Проверка регистрации пользователя
  """
  @spec registered?(user :: pid()) :: boolean
  def registered?(user) do
    User.get_param(user, :registered?)
  end

  @doc """
    Возвращает никнейм пользователя
  """
  @spec nick(pid()) :: {:ok, String.t()}
  def nick(user) do
    get_param(user, :nick)
  end

  def user(user, login, mode, realname) do
    GenServer.call(user, {:user, login, mode, realname})
  end

  @doc """
    Блокировка пользователя
  """
  @spec lock(pid()) :: :ok
  def lock(user), do: GenServer.cast(user, :lock)

  def quit(user) do
    GenServer.stop(user)
  end

  @doc """
    Отправка сообщения от одного пользователя другому
  """
  @spec privmsg(pid(), pid(), String.t()) :: :ok
  def privmsg(user, target, msg) do
    GenServer.cast(user, {:send_msg, target, msg})
  end

  def handle_cast(:lock, %User{} = user), do: {:noreply, %{user | locked: true}}

  # PRIVMSG

  def handle_cast({:send_msg, target, msg}, user) do
    GenServer.cast(target, {:receive_msg, user, msg})
    {:noreply, user}
  end

  def handle_cast({:receive_msg, author, msg}, %User{socket: socket} = user) do
    message = Reply.reply({:PRIVMSG, from(author), msg})
    :gen_tcp.send(socket, message)
    {:noreply, user}
  end

  def handle_call({:get_param, param}, _, user), do: {:reply, Map.get(user, param), user}

  # NICK

  def handle_call({:nick, _}, _, %User{locked: true} = user) do
    {:reply, {:error, :locked}, user}
  end

  def handle_call({:nick, nick}, _from, user) do
    cond do
      already_registered?(user) -> change_nick(user, nick)
      can_register?(user, :nick) -> register(user, nick)
      true -> set_nick(user, nick)
    end
  end

  # USER

  def handle_call({:user, _, _, _}, _from, %User{registered?: true} = user), do: {:reply, {:error, :already_registered}, user}

  def handle_call({:user, login, mode, realname}, _from, %User{nick: nick} = user) do
    user = %{user | login: login, mode: mode, realname: realname}
    if can_register?(user, :user) do
      user = %{user | registered?: true}
      register_nick(nick)
      {:reply, welcome_reply(user), user}
    else
      {:reply, :ok, user}
    end
  end

  defp nick_valid?(nick) do
    Regex.match?(~r/\A[a-z_\-\[\]\\^{}|`][a-z0-9_\-\[\]\\^{}|`]{2,9}\z/i, nick)
  end

  defp welcome_reply(%User{login: login, nick: nick, host: host}) do
    {:welcome, login: login, nick: nick, host: host}
  end

  defp already_registered?(%User{registered?: value}), do: value

  defp change_nick(%User{nick: old_nick} = user, nick) do
    update_registry(old_nick, nick)
    {:reply, {:ok, nick}, %{user | nick: nick}}
  end

  defp can_register?(%User{login: login}, :nick), do: login != nil
  defp can_register?(%User{nick: nick}, :user), do: nick != nil
  defp register(%User{nick: old_nick} = user, nick) do
    user = %{user | registered?: true, nick: nick}
    update_registry(old_nick, nick)
    {:reply, welcome_reply(user), user}
  end

  defp set_nick(user, nick) do
    {:reply, {:ok, nick}, %{user | nick: nick}}
  end

  defp update_registry(from, to) do
    register_nick(to)
    unregister_nick(from)
  end

  defp register_nick(nick) do
    Registry.register(UserRegistry, nick, self())
  end

  defp unregister_nick(nil), do: nil
  defp unregister_nick(nick) do
    Registry.unregister(UserRegistry, nick)
  end

  defp from(%User{nick: nick, login: login}) do
    "#{nick}!#{login}@#{@server_name}"
  end
end
