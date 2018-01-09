defmodule IRC.Reply do
  @moduledoc """
    Отвечает за формирование ответа от сервера
  """

  def response_codes do
    %{
      ERR_NICKNAMEINUSE:    433,
      ERR_ERRONEUSNICKNAME: 432,
      ERR_NONICKNAMEGIVEN:  431,
      ERR_UNAVAILRESOURCE:  437
    }
  end

  defstruct [:code, :msg]

  @doc """
    Вывод ошибок
  """

  def error({:ERR_UNAVAILRESOURCE, nick}) do
    "<#{nick}> :Nick/channel is temporarily unavailable"
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
  def error(_) do "Unknown error" |> format end

  @doc """
    Вывод успешно завершенных комманд
  """
  def success do "" end
  def success(_params), do: success()

  defp format(str), do: "#{str}\r\n"
end
