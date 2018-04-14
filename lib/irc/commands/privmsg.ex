defmodule IRC.Commands.Privmsg do
  alias IRC.{User, UserRegistry}

  @type target :: String.t()
  @type msg :: String.t()
  @type no_nick :: {:error, {:ERR_NOSUCHNICK, target :: target}}
  @type no_server :: {:error, {:ERR_NOSUCHSERVER, String.t}}
  @type away :: {:ok, {:RPL_AWAY, target :: target, msg :: msg}}
  @type response :: no_nick | no_server | away | :ok

  @spec run(author_pid :: pid(), target, String.t()) :: response
  def run(%User{pid: author_pid} = source, target, msg) do
    case UserRegistry.get(target) do
      {:error, msg} -> {:error, msg}
      target_pid ->
        User.privmsg(author_pid, target_pid, msg)
        # TODO: метод User.info(user) должен содержать всю информацию о пользвателе
        # и вызываться при выполнении команды
        source |> check_away(User.info(target_pid))
    end
  end

  defp check_away(_source, %User{away_msg: nil}) do
    :ok
  end
  defp check_away(%User{nick: nick}, %User{away_msg: away_msg, nick: target_nick}) do
    {:ok, {:RPL_AWAY, nick, target_nick, away_msg}}
  end
end
