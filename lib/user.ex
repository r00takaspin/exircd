defmodule User do
  @docmodule """
    Процесс хранящий все данные пользователя
  """

  defstruct nick: "", locked: false

  use GenServer

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
  def nick(user, nick) do
    GenServer.call(user, {:nick, nick})
  end

  @doc """
    Блокировка пользователя
  """
  def lock(user), do: GenServer.cast(user, :lock)

  @doc """
    Проверка пользователя на предмет блокировки
  """
  def locked?(user), do: GenServer.call(:user, :is_locked)


  def handle_call({:nick, _}, _, %User{locked: true} = user), do: { :reply, {:error, :locked}, user }
  def handle_call({:nick, nick}, _from, %User{} = user) do
    nick
    |> nick_valid?
    |> case do
         true -> {:reply, {:ok, nick}, %{user | nick: nick}}
         false -> {:reply, {:error, :nickinvalid}, user}
       end
  end

  def handle_call(:is_locked, _, user), do: {:reply, :ok}

  def handle_cast(:lock, %User{} = user), do: {:noreply, %{user | locked: true}}

  defp nick_valid?(nick), do: Regex.match?(~r/\A[a-z_\-\[\]\\^{}|`][a-z0-9_\-\[\]\\^{}|`]{2,9}\z/i, nick)
end
