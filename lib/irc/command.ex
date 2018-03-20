defmodule IRC.Command do
  @moduledoc """
    Парсинг и выполнение IRC комманд
  """

  alias IRC.UserRegistry
  alias IRC.Commands.{Nick, User}

  @doc ~S"""
  Parses the given `line` into a command.

  ##Examples
    iex> IRC.Command.parse("NICK john")
    {:ok, {:nick, "john"}}

    iex> IRC.Command.parse("NICK john\r\n")
    {:ok, {:nick, "john"}}

    iex> IRC.Command.parse("NICK john  \r\n")
    {:ok, {:nick, "john"}}

    iex> IRC.Command.parse("UNKNOWN asdasdad")
    {:error, "Unknown command"}

    iex> IRC.Command.parse("NICK")
    {:ok, :nick}

    iex> IRC.Command.parse("USER guest 0 * :Ronnie Reagan")
    {:ok, {:user, "guest", "0", "Ronnie Reagan"}}
    iex> IRC.Command.parse("USER 2340-230489 923")
    {:ok, :user}

    iex> IRC.Command.parse(true)
    {:error, "Unknown command"}
  """
  def parse(line) when is_binary(line) do
    line
    |> String.split
    |> case do
        ["NICK"] ->
          {:ok, :nick}
        ["NICK", nick] ->
          {:ok, {:nick, nick}}
        ["USER", login, mode, "*", first_name, last_name] ->
          {:ok, {:user, login, mode, "#{String.replace(first_name, ":", "")} #{last_name}"}}
        ["USER" | [_ | _]] -> {:ok, :user}
        _ -> {:error, "Unknown command"}
       end
  end
  def parse(_), do: {:error, "Unknown command"}

  def run(_session, :nick), do: {:error, {:ERR_NONICKNAMEGIVEN}}
  def run(_session, :user), do: {:error, {:ERR_NEEDMOREPARAMS, "USER"}}

  @spec run(IRC.Session.t, {:nick, nick::String.t}) :: :ok | {:error, term}
  def run(session, {:nick, nick}) do
    Nick.run(nick, session, UserRegistry)
  end
  def run(session, {:user, login, mode, realname}) do
    session
    |> IRC.Session.user
    |> User.run(login, mode, realname)
  end
end
