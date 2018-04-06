defmodule IRC.Reply do
  @moduledoc """
    Отвечает за формирование ответа от сервера
  """

  @servername Application.get_env(:exircd, :servername)
  @version Application.get_env(:exircd, :version)
  @start_date Application.get_env(:exircd, :server_created)
  @user_modes Application.get_env(:exircd, :user_modes)
  @chanel_modes Application.get_env(:exircd, :chanel_modes)

  def response_codes do
    %{
      # WELCOME REPLYES:
      RPL_WELCOME:          "001",
      RPL_YOURHOST:         "002",
      RPL_CREATED:          "003",
      RPL_MYINFO:           "004",

      # PRIVMSG
      ERR_NOSUCHNICK:       "401",
      ERR_NORECIPIENT:      "411",
      ERR_NOTEXTTOSEND:     "412",

      ERR_NICKNAMEINUSE:    "433",
      ERR_ERRONEUSNICKNAME: "432",
      ERR_NONICKNAMEGIVEN:  "431",
      ERR_UNAVAILRESOURCE:  "437",

      ERR_NOTREGISTERED:    "451",

      ERR_NEEDMOREPARAMS:   "461",
      ERR_ALREADYREGISTRED: "462"
    }
  end

  defstruct [:code, :msg]

  @doc """
    Вывод ошибок
  """

  def error({:ERR_NEEDMOREPARAMS, command}) do
    format :ERR_NEEDMOREPARAMS, "<#{command}> :Not enough parameters"
  end
  def error({:ERR_UNAVAILRESOURCE, nick}) do
    format :ERR_UNAVAILRESOURCE, "<#{nick}> :Nick/channel is temporarily unavailable"
  end
  def error({:ERR_NONICKNAMEGIVEN}) do
    format :ERR_NONICKNAMEGIVEN, ":No nickname given"
  end
  def error({:ERR_ERRONEUSNICKNAME, nick}) do
    format :ERR_ERRONEUSNICKNAME, "<#{nick}> :Erroneous nickname"
  end
  def error({:ERR_NICKNAMEINUSE, nick}) do
    format :ERR_NICKNAMEINUSE, "<#{nick}> :Nickname is already in use"
  end
  def error({:ERR_ALREADYREGISTRED}) do
    format :ERR_ALREADYREGISTRED, ":Unauthorized command (already registered)"
  end
  def error({:ERR_NOTREGISTERED}) do
    format :ERR_NOTREGISTERED, ":You have not registered"
  end
  def error({:ERR_NOSUCHNICK, nick}) do
    format :ERR_NOSUCHNICK, "<#{nick}> :No such nick/channel"
  end
  def error({:ERR_NORECIPIENT, command}) do
    format :ERR_NORECIPIENT, ":No recipient given (<#{command}>)"
  end
  def error({:ERR_NOTEXTTOSEND}) do
    format :ERR_NOTEXTTOSEND, ":No text to send"
  end

  def error(msg), do: "Unknown error: #{msg}\r\n"

  @doc """
    Вывод успешно завершенных комманд
  """
  def reply, do: nil
  def reply(list) when is_list(list) do
    list |> List.foldl("",fn(r, str) -> str <> reply(r) end)
  end

  def reply({:RPL_WELCOME, nick, login, host}) do
    format :RPL_WELCOME, "Welcome to the Internet Relay Network #{nick}!#{login}@#{host}>"
  end
  def reply(:RPL_YOURHOST) do
    format :RPL_YOURHOST, "Your host is #{@servername}, running version #{@version}"
  end
  def reply(:RPL_CREATED) do
    format :RPL_CREATED, "This server was created #{@start_date}"
  end
  def reply(:RPL_MYINFO) do
    format :RPL_MYINFO, "#{@servername} #{@version} #{@user_modes} #{@chanel_modes}"
  end
  def reply(_params), do: reply()

  defp reply_id(code), do: response_codes()[code]

  defp format(code, str) do
    "#{reply_id(code)} #{str}\r\n"
  end
end
