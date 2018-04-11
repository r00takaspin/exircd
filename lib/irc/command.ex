defmodule IRC.Command do
  @moduledoc """
    Парсинг и выполнение IRC комманд
  """

  alias IRC.Commands.{Nick, User, Privmsg, Away}

  @doc ~S"""
    iex> IRC.Command.parse(["NICK", "john"])
    {:ok, {:nick, "john"}}


    iex> IRC.Command.parse(["UNKNOWN", "asdasdad"])
    {:error, "Unknown command"}

    iex> IRC.Command.parse(["NICK"])
    {:error, {:ERR_NONICKNAMEGIVEN}}

    iex> IRC.Command.parse(["USER", "guest", "0", "*", "Ronnie Reagan"])
    {:ok, {:user, "guest", "0", "Ronnie Reagan"}}

    iex> IRC.Command.parse(["USER", "vasya", "*", "*", "Vasya"])
    {:ok, {:user, "vasya", "*", "Vasya"}}

    iex> IRC.Command.parse(["USER", "2340-230489 923"])
    {:error, {:ERR_NEEDMOREPARAMS, "USER"}}

    iex> IRC.Command.parse(true)
    {:error, "Unknown command"}

    iex> IRC.Command.parse(["PRIVMSG", "rick", "Hello Morty"])
    {:ok, {:privmsg, "rick", "Hello Morty"}}

    iex> IRC.Command.parse(["PRIVMSG"])
    {:error, {:ERR_NORECIPIENT}}

    iex> IRC.Command.parse(["PRIVMSG", "voldemar"])
    {:error, {:ERR_NOTEXTTOSEND}}

    iex> IRC.Command.parse(["AWAY"])
    {:ok, :away}

    iex> IRC.Command.parse(["AWAY", "msg"])
    {:ok, {:away, "msg"}}
  """

  def parse(["AWAY"]), do: {:ok, :away}
  def parse(["AWAY", msg]), do: {:ok, {:away, msg}}

  def parse(["USER"]), do: {:error, {:ERR_NEEDMOREPARAMS, "USER"}}
  def parse(["USER", login, mode, "*", realname]), do: {:ok, {:user, login, mode, realname}}
  def parse(["USER" | _tail]), do: {:error, {:ERR_NEEDMOREPARAMS, "USER"}}

  def parse(["NICK"]), do: {:error, {:ERR_NONICKNAMEGIVEN}}
  def parse(["NICK", nick]), do: {:ok, {:nick, nick}}

  def parse(["PRIVMSG"]), do: {:error, {:ERR_NORECIPIENT}}
  def parse(["PRIVMSG", nick, message]), do: {:ok, {:privmsg, nick, message}}
  def parse(["PRIVMSG", _nick]), do: {:error, {:ERR_NOTEXTTOSEND}}

  def parse(_args), do: {:error, "Unknown command"}

  def parse_line(line) do
    line
    |> String.trim
    |> String.split(":", trim: true)
    |> case do
      [^line] -> String.split(line, [" "], trim: true)
      [head | tail] -> parse_line(head) ++ tail
    end
  end

  @spec run(user :: pid(), {:nick, String.t}) :: :ok | {:error, term}
  def run(user, {:nick, nick}) do
    Nick.run(user, nick)
  end
  def run(user, {:user, login, mode, realname}) do
    User.run(user, login, mode, realname)
  end
  def run(user, {:privmsg, target, msg}) do
    Privmsg.run(user, target, msg)
  end
  def run(user, {:away, msg}) do
    Away.run(user, msg)
  end
  def run(user, :away) do
    Away.run(user)
  end
end
