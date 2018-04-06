defmodule IRC.Commands.Privmsg do
  alias IRC.{User, UserRegistry}

  def run(user, target, msg) do
    if User.registered?(user) do
      case UserRegistry.lookup(target) do
        false -> {:error, {:ERR_NOSUCHNICK, target}}
        _ -> :ok
      end
    else
      {:error, {:ERR_NOTREGISTERED}}
    end
  end
end
