defmodule IRC.Commands.Privmsg do
  alias IRC.{User, UserRegistry}

  @server_name Application.get_env(:exircd, :servername)

  @type target :: String.t()
  @type msg :: String.t()
  @type no_nick :: {:error, {:ERR_NOSUCHNICK, target :: target}}
  @type no_server :: {:error, {:ERR_NOSUCHSERVER, String.t}}
  @type away :: {:ok, {:RPL_AWAY, target :: target, msg :: msg}}
  @type response :: no_nick | no_server | away | :ok

  @spec run(author_pid :: pid(), target, String.t()) :: response
  def run(author_pid, target, msg) do
    case get_username(target) do
      {:error, msg} -> {:error, msg}
      nick ->
        case UserRegistry.lookup(nick) do
          false -> {:error, {:ERR_NOSUCHNICK, target}}
          {:ok, target_pid} ->
            User.privmsg(author_pid, target_pid, msg)
            # TODO: метод User.info(user) должен содержать всю информацию о пользвателе
            # и вызываться при выполнении команды
            if User.away?(target_pid) do
              {:ok, {:RPL_AWAY, target, User.get_param(target_pid, :away_msg)}}
            else
              :ok
            end
        end
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
