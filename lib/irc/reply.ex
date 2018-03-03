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
      RPL_WELCOME:          001,
      RPL_YOURHOST:         002,
      RPL_CREATED:          003,
      RPL_MYINFO:           004,

      ERR_NICKNAMEINUSE:    433,
      ERR_ERRONEUSNICKNAME: 432,
      ERR_NONICKNAMEGIVEN:  431,
      ERR_UNAVAILRESOURCE:  437,

      ERR_NEEDMOREPARAMS:   461,
      ERR_ALREADYREGISTRED: 462
    }
  end

  defstruct [:code, :msg]

  @doc """
    Вывод ошибок
  """

  def error({:ERR_NEEDMOREPARAMS, command}) do
    code = response_codes()[:ERR_NEEDMOREPARAMS]
    "#{code} <#{command}> :Not enough parameters"
    |> format
  end
  def error({:ERR_UNAVAILRESOURCE, nick}) do
    code = response_codes()[:ERR_NICKNAMEINUSE]
    "#{code} <#{nick}> :Nick/channel is temporarily unavailable"
    |> format
  end
  def error({:ERR_NONICKNAMEGIVEN}) do
    "#{response_codes()[:ERR_NONICKNAMEGIVEN]} :No nickname given"
    |> format
  end
  def error({:ERR_ERRONEUSNICKNAME, nick}) do
    "#{response_codes()[:ERR_ERRONEUSNICKNAME]} <#{nick}> :Erroneous nickname"
    |> format
  end
  def error({:ERR_NICKNAMEINUSE, nick}) do
    code = response_codes()[:ERR_NICKNAMEINUSE]
    "#{code} <#{nick}> :Nickname is already in use"
    |> format
  end
  def error({:ERR_ALREADYREGISTRED}) do
    code = response_codes()[:ERR_ALREADYREGISTRED]
    "#{code} :Unauthorized command (already registered)"
    |> format
  end
  def error(_msg), do: "Unknown error" |> format

  @doc """
    Вывод успешно завершенных комманд
  """
  def reply do "" end
  def reply(list) when is_list(list) do
    list |> List.foldl("",fn(r, str) -> str <> reply(r) end)
  end

  def reply({:RPL_WELCOME, nick, login, host}) do
    "#{response_codes()[:RPL_WELCOME]} Welcome to the Internet Relay Network #{nick}!#{login}@#{host}>"
    |> format
  end
  def reply(:RPL_YOURHOST) do
    "#{response_codes()[:RPL_YOURHOST]} Your host is #{@servername}, running version #{@version}"
    |> format
  end
  def reply(:RPL_CREATED) do
    "#{response_codes()[:RPL_CREATED]} This server was created #{@start_date}"
    |> format
  end
  def reply(:RPL_MYINFO) do
    "#{response_codes()[:RPL_MYINFO]} #{@servername} #{@version} #{@user_modes} #{@chanel_modes}"
    |> format
  end
  def reply(_params), do: reply()

  defp format(str), do: "#{str}\r\n"
end
