defmodule UserRegistryTest do
  use ExUnit.Case, async: true

  alias IRC.UserRegistry

  setup do
    {:ok, registry} = UserRegistry.start_link([])
    %{registry: registry}
  end

  describe "lookup/1" do
    @nick "test"
    test "return error if empty repository", %{registry: registry} do
      assert registry |> UserRegistry.lookup(@nick) == :error
    end

    test "find existing nickname", %{registry: registry} do
      registry |> UserRegistry.create(@nick)
      {:ok, pid} = registry |> UserRegistry.lookup(@nick)
      assert is_pid(pid)
    end
  end

  describe "change_nick/3" do

    @old_nick "poopa"
    @new_nick "loopa"
    test "user not found", %{registry: registry} do
      subject = registry |> UserRegistry.change_nick(@old_nick, @new_nick)
      assert  subject == {:error, :not_found}
    end

    test "change nick several times", %{registry: registry} do
      registry |> UserRegistry.create(@old_nick)
      {:ok, _} = registry |> UserRegistry.change_nick(@old_nick, @new_nick)

      {:ok, loopa} = registry |> UserRegistry.lookup(@new_nick)
      assert {:ok, @new_nick} == loopa |> IRC.User.nick

      {:ok, _} = registry |> UserRegistry.change_nick(@new_nick, @old_nick)
    end
  end

  describe "ban/2" do
    @poopa "poopa"
    test "ban existing user: #{@poopa}", %{registry: registry} do
      registry |> UserRegistry.create(@poopa)
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
