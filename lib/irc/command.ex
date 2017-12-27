defmodule IRC.Command do
  @moduledoc """
    Парсинг и выполнение IRC комманд
  """

  alias IRC.{UserRegistry, Commands.Nick}

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
  """
  def parse(line) do
    line
    |> String.split
    |> case do
        ["NICK"] -> {:ok, :nick}
        ["NICK", nick] -> {:ok, {:nick, nick}}
        _ -> {:error, "Unknown command"}
       end
  end

  @spec run(IRC.Session.t, :nick) :: {:error, term}
  def run(session, :nick) do
    Nick.run(nil, session, UserRegistry)
  end
  @spec run(IRC.Session.t, {:nick, nick::String.t}) :: :ok | {:error, term}
  def run(session, {:nick, nick}) do
    Nick.run(nick, session, UserRegistry)
  end
end
