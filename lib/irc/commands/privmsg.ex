defmodule IRC.Commands.Privmsg do
  alias IRC.User

  def run(user, target, msg) do
    if User.registered?(user) do
      :ok
    else
      {:error, {:ERR_NOTREGISTERED}}
    end
  end
end
