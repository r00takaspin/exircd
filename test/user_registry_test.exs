defmodule UserRegistryTest do
  use ExUnit.Case, async: true

  alias IRC.{User, UserRegistry}

  setup do
    {:ok, registry} = UserRegistry.start_link([])
    {:ok, user} = User.start_link([])
    %{registry: registry, user: user}
  end

  describe "lookup/1" do
    @nick "test"
    test "return error if empty repository", %{registry: registry} do
      assert registry |> UserRegistry.lookup(@nick) == :error
    end

    test "find existing nickname", %{registry: registry, user: user} do
      registry |> UserRegistry.create(@nick, user)
      {:ok, pid} = registry |> UserRegistry.lookup(@nick)
      assert is_pid(pid)
    end
  end

  describe "change_nick/3" do

    @old_nick "poopa"
    @new_nick "loopa"

    test "user not found", %{registry: registry, user: user} do
      subject = registry |> UserRegistry.change_nick(@old_nick, @new_nick, user)
      assert  subject == {:error, :not_found}
    end

    test "change nick several times", %{registry: registry, user: user} do
      registry |> UserRegistry.create(@old_nick, user)
      {:ok, _} = registry |> UserRegistry.change_nick(@old_nick, @new_nick, user)

      {:ok, loopa} = registry |> UserRegistry.lookup(@new_nick)
      assert @new_nick == loopa |> IRC.User.nick

      {:ok, _} = registry |> UserRegistry.change_nick(@new_nick, @old_nick, user)
    end
  end

  describe "ban/2" do
    @poopa "poopa"
    test "ban existing user: #{@poopa}", %{registry: registry, user: user} do
      registry |> UserRegistry.create(@poopa, user)
      assert :ok == registry |> UserRegistry.ban(@poopa)
    end

    @loopa "loopa"
    test "ban not existing user: #{@loopa}", %{registry: registry} do
      assert :ok == registry |> UserRegistry.ban(@loopa)
    end
  end

  describe "banned?/2" do
    @poopa "poopa"
    test "false if user: #{@poopa} doesn't exists", %{registry: registry} do
      refute registry |> UserRegistry.banned?(@poopa)
    end

    test "true if user: #{@poopa} is already banned", %{registry: registry} do
      registry |> UserRegistry.ban(@poopa)
      assert registry |> UserRegistry.banned?(@poopa)
    end
  end
end
