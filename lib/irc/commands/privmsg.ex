defmodule IRC.Commands.Privmsg do
  alias IRC.{User, UserRegistry}

  @type target :: String.t()
  @type no_nick :: {:error, {:ERR_NOSUCHNICK, target :: target}}
  @type not_registered :: {:error, {:ERR_NOTREGISTERED}}
  @type response :: no_nick | not_registered | :ok

  @spec run(author_pid :: pid(), target, String.t()) :: response
  def run(author_pid, target, msg) do
    if User.registered?(author_pid) do
      case UserRegistry.lookup(target) do
        false -> {:error, {:ERR_NOSUCHNICK, target}}
        {:ok, target_pid} -> User.privmsg(author_pid, target_pid, msg)
      end
    else
      {:error, {:ERR_NOTREGISTERED}}
    end
  end
end
