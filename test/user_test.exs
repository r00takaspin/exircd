defmodule UserTest do
  use ExUnit.Case

  alias IRC.User
  alias IRC.Support.Factory

  setup do
    {:ok, user} = Factory.user()
    %{user: user}
  end

  setup_all do
    {:ok, _} = Registry.start_link(keys: :unique, name: UserRegistry)
    on_exit fn -> IRC.UserRegistry.reset_meta() end
    :ok
  end

  describe "lock/2" do
    test "locks user", %{user: user} do
      assert user |> User.lock == :ok
    end
  end

  describe "nick/2" do
    def subject(user, nick), do: User.nick(user, nick)

    @new_name "valid_nick"

    test "change nickname to #{@new_name}", %{user: user} do
      assert user |> subject(@new_name) == {:ok, @new_name}
    end

    test "empty nickname", %{user: user} do
      assert user |> subject("") == {:error, {:nickinvalid, ""}}
    end

    @long_nick "verylongnickname"
    test "nickname more than 9+ characters", %{user: user} do
      assert user |> subject(@long_nick) == {:error, {:nickinvalid, @long_nick}}
    end

    test "user is locked", %{user: user} do
      user |> User.lock

      assert user |> subject("any") == {:error, :locked}
    end
  end

  @login "poopa"
  @mode "w"
  @real_name "Vasya Pupkin"

  describe "user/4" do
    test "register user", %{user: user} do
      result = user |> User.user(@login, @mode, @real_name)
      assert :ok == result
    end

    test "register twice", %{user: user} do
      User.nick(user, "poopa")
      user |> User.user(@login, @mode, @real_name)
      result = user |> User.user(@login, @mode, @real_name)

      assert {:error, :already_registered} == result
    end
  end

  describe "registered?" do
    test "new user is not registered", %{user: user} do
      assert User.registered?(user) == false
    end
  end
end
