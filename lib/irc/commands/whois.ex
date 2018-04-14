defmodule IRC.Commands.Whois do
  alias IRC.{User, UserRegistry}

  def run(%User{pid: user}, target) do
    case UserRegistry.get(target) do
      {:error, error} -> {:error, error}
      target_pid -> :ok
    end
  end
end