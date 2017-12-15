defmodule IRC.Command do
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
    {:error, :ERR_NONICKNAMEGIVEN}
  """
  def parse(line) do
    line
    |> String.split
    |> case do
        ["NICK"] -> {:error, :ERR_NONICKNAMEGIVEN}
        ["NICK", nick] -> {:ok, {:nick, nick}}
        _ -> {:error, "Unknown command"}
       end
  end

  def run({:nick, nick}) do
    nick
    |> UserRegistry.find
    |> case do
         {:ok, user} -> User.nick(user, nick)
       end
  end
end
