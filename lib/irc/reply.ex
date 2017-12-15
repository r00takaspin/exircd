defmodule IRC.Reply do
  def response_codes do
    %{
      ERR_ERRONEUSNICKNAME: 432,
      ERR_NONICKNAMEGIVEN: 431,
      ERR_UNAVAILRESOURCE: 437,
    }
  end

  defstruct [:code, :msg]

  def error(:ERR_NONICKNAMEGIVEN) do
    "#{response_codes[:ERR_NONICKNAMEGIVEN]} <nick> :Erroneous nickname"
    |> format
  end

  def error(_) do "Unknown error" |> format end

  defp format(str), do: "#{str}\r\n"
end
