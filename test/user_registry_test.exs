defmodule UserRegistryTest do
  use ExUnit.Case

  alias IRC.{User, Support.Factory}

  setup_all do
    {:ok, _} = Registry.start_link(keys: :unique, name: UserRegistry)
    :ok
  end

  setup do
    on_exit fn -> IRC.UserRegistry.reset_meta() end
  end


  describe "find_or_create_by_socket/2" do
    test "finds user by socket" do
      {:ok, new_user} = Factory.user()

      socket = User.get_param(new_user, :socket)

      {:ok, found_user} = IRC.UserRegistry.find_or_create_by_socket(socket)

      assert new_user == found_user
    end

    test "creates user by new socket" do
      {:ok, socket} = :gen_tcp.listen(0, [:binary, packet: :line, active: false, reuseaddr: true])

      {:ok, pid} = IRC.UserRegistry.find_or_create_by_socket(socket)

      assert is_pid(pid)
    end
  end

  describe "lookup/1" do
    @nick "test"
    test "return error if empty repository" do
      refute IRC.UserRegistry.lookup(@nick)
    end

    test "find existing nickname" do
      {:ok, user} = Factory.user()
      User.nick(user, @nick)
      User.user(user, "vasya", "*", "Vasya Petrov")
      {:ok, pid} = IRC.UserRegistry.lookup(@nick)

      assert User.get_param(pid, :nick) == @nick
    end
  end

  describe "nick/2" do
    setup do
      user = Factory.user(:registered, "vasya")
      %{user: user}
    end

    @old_nick "poopa"
    @new_nick "loopa"

    test "set nickname", %{user: user} do
      assert {:ok, _pid} = IRC.UserRegistry.nick(user, @new_nick)
    end

    test "change nick several times", %{user: user} do
      IRC.UserRegistry.nick(user, @old_nick)
      {:ok, _} = IRC.UserRegistry.nick(user, @new_nick)

      {:ok, loopa} = IRC.UserRegistry.lookup(@new_nick)
      assert @new_nick == loopa |> IRC.User.nick

      {:ok, poopa} = IRC.UserRegistry.nick(user, @old_nick)
      assert User.nick(poopa) == @old_nick
    end
  end

  describe "ban/2" do
    setup do
      {:ok, user} = Factory.user()
      %{user: user}
    end

    @poopa "poopa"
    test "ban existing user: #{@poopa}", %{user: user} do
      IRC.UserRegistry.nick(user, @poopa)
      assert :ok == IRC.UserRegistry.ban(@poopa)
    end

    @loopa "loopa"
    test "ban not existing user: #{@loopa}" do
      assert :ok == IRC.UserRegistry.ban(@loopa)
    end
  end

  describe "banned?/2" do
    @poopa "poopa"
    test "false if user: #{@poopa} doesn't exists" do
      refute IRC.UserRegistry.banned?(@poopa)
    end

    test "true if user: #{@poopa} is already banned" do
      IRC.UserRegistry.ban(@poopa)
      assert IRC.UserRegistry.banned?(@poopa)
    end
  end
end
