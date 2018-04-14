defmodule UserTest do
  use ExUnit.Case

  alias IRC.User
  alias IRC.Support.Factory

  @login "poopa"
  @mode "w"
  @real_name "Vasya Pupkin"

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

  describe "away/2" do
    test "set away message", %{user: user} do
      User.away(user, "Away")

      assert User.get_param(user, :away_msg) == "Away"
    end

    test "unset away message", %{user: user} do
      User.away(user, "Away")
      user |> User.away("Away")
      user |> User.away()

      refute User.get_param(user, :away_msg)
    end
  end

  describe "info/1" do
    test "new user", %{user: user} do
      User.nick(user, "vasya")
      User.user(user, "vasya", "*", "Vasya Pupkin")
      info = User.info(user)

      assert %User{pid: ^user, nick: "vasya", realname: "Vasya Pupkin"} = info
    end
  end
end
