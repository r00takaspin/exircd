defmodule IRC.Reply do
  @moduledoc """
    Отвечает за формирование ответа от сервера
  """

  @serverhost Application.get_env(:exircd, :serverhost)
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

      # AWAY
      RPL_AWAY:             "301",
      RPL_UNAWAY:           "305",
      RPL_NOWAWAY:          "306",

      #WHOIS
      RPL_WHOISUSER:        "311",
      RPL_WHOISSERVER:      "312",
      RPL_WHOISOPERATOR:    "313",
      RPL_WHOISIDLE:        "317",
      RPL_ENDOFWHOIS:       "318",
      RPL_WHOISCHANNELS:    "319",
      # PRIVMSG
      ERR_NOSUCHNICK:       "401",
      ERR_NOSUCHSERVER:     "402",
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
    format :ERR_NICKNAMEINUSE, "* #{nick} :Nickname is already in use"
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
  def error({:ERR_NOSUCHSERVER, servername}) do
    format :ERR_NOSUCHSERVER, "#{servername} :No such server"
  end

  def error(msg), do: "Unknown error: #{msg}\r\n"

  @doc """
    Вывод успешно завершенных комманд
  """
  def reply, do: nil
  def reply(list) when is_list(list) do
    list |> List.foldl("",fn(r, str) -> str <> reply(r) end)
  end
  def reply({:RPL_AWAY, to, nick, msg}) do
    format :RPL_AWAY, to, "#{nick} :#{msg}"
  end
  def reply({:RPL_UNAWAY, to}) do
    format :RPL_UNAWAY, to, ":You are no longer marked as being away"
  end
  def reply({:RPL_NOWAWAY, to}) do
    format :RPL_NOWAWAY, to, ":You have been marked as being away"
  end
  def reply({:PRIVMSG, from, to, msg}) do
    format ":#{from} PRIVMSG #{to} :#{msg}"
  end
  def reply({:RPL_WELCOME, nick, login, host}) do
    format :RPL_WELCOME, nick, "Welcome to the Internet Relay Network #{nick}!#{login}@#{host}"
  end
  def reply({:RPL_YOURHOST, to}) do
    format :RPL_YOURHOST, to, "Your host is #{@serverhost}, running version #{@version}"
  end
  def reply({:RPL_CREATED, to}) do
    format :RPL_CREATED, to, "This server was created #{@start_date}"
  end
  def reply({:RPL_MYINFO, to}) do
    format :RPL_MYINFO, to, "#{@serverhost} #{@version} #{@user_modes} #{@chanel_modes}"
  end

  defp reply_id(code), do: response_codes()[code]

  defp format(str), do: "#{str}\r\n"

  defp format(code, str) do
    ":#{@serverhost} #{reply_id(code)} #{str}\r\n"
  end

  defp format(code, to, str) do
    ":#{@serverhost} #{reply_id(code)} #{to} #{str}\r\n"
  end
end
