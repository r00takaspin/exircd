defmodule IRC.Commands.Privmsg do
  alias IRC.{User, UserRegistry}

  @server_name Application.get_env(:exircd, :servername)

  @type target :: String.t()
  @type no_nick :: {:error, {:ERR_NOSUCHNICK, target :: target}}
  @type not_registered :: {:error, {:ERR_NOTREGISTERED}}
  @type response :: no_nick | not_registered | :ok

  @spec run(author_pid :: pid(), target, String.t()) :: response
  def run(author_pid, target, msg) do
    if User.registered?(author_pid) do
      case get_username(target) do
        {:error, msg} -> {:error, msg}
        nick ->
          case UserRegistry.lookup(nick) do
            false -> {:error, {:ERR_NOSUCHNICK, target}}
            {:ok, target_pid} -> User.privmsg(author_pid, target_pid, msg)
          end
      end
    else
      {:error, {:ERR_NOTREGISTERED}}
    end
  end

  defp get_username(username) do
    case String.split(username, "@") do
      [^username] -> username
      [username, @server_name] -> username
      [_username, servername] -> {:error, {:ERR_NOSUCHSERVER, servername}}
    end
  end
end
