defmodule IRC.Commands.NickTest do
  use ExUnit.Case

  alias IRC.{Commands.Nick, Support.UserFactory}

  setup_all do
    {:ok, _} = Registry.start_link(keys: :unique, name: UserRegistry)
    :ok
  end

  setup do
    on_exit fn -> IRC.UserRegistry.reset_meta() end
  end

  describe "run/3" do
    def subject(user, nick) do
      Nick.run(user, nick)
    end

    setup do
      {:ok, user} = UserFactory.create_user()

      %{user: user}
    end

    @long_nick "very_long_nick_name_here"
    test "long nickname: #{@long_nick}", %{user: user} do
      body = {:error, {:ERR_ERRONEUSNICKNAME, @long_nick}}

      assert body == subject(user, @long_nick)
    end

    @short_nick "aa"
    test "short nickname: #{@short_nick}", %{user: user} do
      body = {:error, {:ERR_ERRONEUSNICKNAME, @short_nick}}
      assert  body == subject(user, @short_nick)
    end

    @used_nickname "voldemar"
    test "nickname in use: #{@used_nickname}", %{user: user} do
      {:ok, user2} = UserFactory.create_user()
      IRC.UserRegistry.nick(user2, @used_nickname)
      response = {:error, {:ERR_NICKNAMEINUSE, @used_nickname}}
      assert response == subject(user, @used_nickname)
    end

    test "session has attached user", %{user: user} do
      poopa = "poopa"
      loopa = "loopa"

      assert :ok == subject(user, poopa)
      assert :ok == subject(user, loopa)
    end

    test "register valid user", %{user: user} do
      assert :ok == subject(user, "valid_nick")
    end

    @banned_nickname "loopa"
    test "banned nickname: #{@banned_nickname}", %{user: user} do
      IRC.UserRegistry.ban(@banned_nickname)
      response = {:error, {:ERR_UNAVAILRESOURCE, @banned_nickname}}
      assert response == subject(user, @banned_nickname)
    end
  end
end
