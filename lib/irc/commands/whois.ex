defmodule IRC.Commands.Whois do
  alias IRC.UserRegistry

  def run(user, target) do
    case UserRegistry.get(target) do
      {:error, error} -> {:error, error}
      target_pid -> :ok
    end
  end
end