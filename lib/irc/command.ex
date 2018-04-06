defmodule IRC.Command do
  @moduledoc """
    Парсинг и выполнение IRC комманд
  """

  alias IRC.Commands.{Nick, User, Privmsg}

  @doc ~S"""
    iex> IRC.Command.parse("NICK john")
    {:ok, {:nick, "john"}}

    iex> IRC.Command.parse("NICK john\r\n")
    {:ok, {:nick, "john"}}

    iex> IRC.Command.parse("NICK john  \r\n")
    {:ok, {:nick, "john"}}

    iex> IRC.Command.parse("UNKNOWN asdasdad")
    {:error, "Unknown command"}

    iex> IRC.Command.parse("NICK")
    {:error, {:ERR_NONICKNAMEGIVEN}}

    iex> IRC.Command.parse("USER guest 0 * :Ronnie Reagan")
    {:ok, {:user, "guest", "0", "Ronnie Reagan"}}
    iex> IRC.Command.parse("USER 2340-230489 923")
    {:error, {:ERR_NEEDMOREPARAMS, "USER"}}

    iex> IRC.Command.parse(true)
    {:error, "Unknown command"}

    iex> IRC.Command.parse("PRIVMSG rick :Hello Morty")
    {:ok, {:privmsg, "rick", "Hello Morty"}}

    iex> IRC.Command.parse("PRIVMSG")
    {:error, {:ERR_NORECIPIENT}}

    iex> IRC.Command.parse("PRIVMSG voldemar :")
    {:error, {:ERR_NOTEXTTOSEND}}
  """
  def parse("USER"), do: {:error, {:ERR_NEEDMOREPARAMS, "USER"}}
  def parse("USER" <> _ = line), do: split_args(line)

  def parse("NICK"), do: {:error, {:ERR_NONICKNAMEGIVEN}}
  def parse("NICK" <> _ = line), do: split_args(line)

  def parse("PRIVMSG"), do: {:error, {:ERR_NORECIPIENT}}
  def parse("PRIVMSG " <> body) do
    body
    |> String.split(":", trim: true)
    |> Enum.map(&String.trim/1)
    |> case do
        [nick, message] -> {:ok, {:privmsg, nick, message}}
        [nick] -> {:error, {:ERR_NOTEXTTOSEND}}
       end
  end

  defp split_args(line) when is_binary(line) do
    line
    |> String.split
    |> case do
         ["NICK", nick] ->
           {:ok, {:nick, nick}}
         ["USER", login, mode, "*", first_name, last_name] ->
           {:ok, {:user, login, mode, "#{String.replace(first_name, ":", "")} #{last_name}"}}
         ["USER" | _tail] -> {:error, {:ERR_NEEDMOREPARAMS, "USER"}}
         msg -> IO.inspect(msg); {:error, "Unknown command"}
       end
  end
  def parse(_), do: {:error, "Unknown command"}


  @spec run(IRC.Session.t, {:nick, nick::String.t}) :: :ok | {:error, term}
  def run(user, {:nick, nick}) do
    Nick.run(user, nick)
  end
  def run(user, {:user, login, mode, realname}) do
    User.run(user, login, mode, realname)
  end
  def run(user, {:privmsg, target, msg}) do
    Privmsg.run(user, target, msg)
  end
end
