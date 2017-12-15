defmodule UserTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, user} = User.start_link([])
    %{user: user}
  end

  describe "lock/1" do
    test "locks user", %{user: user} do
      assert user |> User.lock == :ok
    end
  end

  describe "nick/1" do
    def subject(user, nick), do: User.nick(user, nick)

    @new_name "valid_nick"

    test "change nickname to #{@new_name}", %{user: user} do
     assert user |> subject(@new_name) == {:ok, @new_name}
    end

    test "empty nickname", %{user: user} do
      assert user |> subject("") == {:error, :nickinvalid}
    end

    test "nickname more than 9+ characters", %{user: user} do
      assert user |> subject("verylongnickname") == {:error, :nickinvalid}
    end

    test "user is locked", %{user: user} do
      user |> User.lock

      assert user |> subject("any") == {:error, :locked}
    end
  end
end