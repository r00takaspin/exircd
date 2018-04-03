defmodule IRC.CommandTest do
  use ExUnit.Case
  doctest IRC.Command

  alias IRC.{Command, Support.UserFactory}

  setup_all do
    {:ok, _} = Registry.start_link(keys: :unique, name: UserRegistry)
    :ok
  end

  setup do
    on_exit fn -> IRC.UserRegistry.reset_meta() end
  end

  describe "run/1" do
    def subject(user, params) do
      Command.run(user, params)
    end

    setup do
      {:ok, user} = UserFactory.create_user()
      %{user: user}
    end

    @long_nick "very_long_nick_name_here"
    @long_error_body {:ERR_ERRONEUSNICKNAME, @long_nick}
    test "long nickname", %{user: user} do
      assert {:error, @long_error_body} == subject(user, {:nick, @long_nick})
    end

    @short_nick "aa"
    @short_error_body {:ERR_ERRONEUSNICKNAME, @short_nick}
    test "short nickname", %{user: user} do
      response = {:error, @short_error_body}
      assert  response == subject(user, {:nick, @short_nick})
    end

    @used_nickname "voldemar"
    @user_nick_body {:ERR_NICKNAMEINUSE, @used_nickname}
    test "nickname in use", %{user: user} do
      IRC.UserRegistry.nick(user, @used_nickname)

      response = {:error, @user_nick_body}
      assert response == subject(user, {:nick, @used_nickname})
    end

    test "no enough params", %{user: user} do
      response = {:error, {:ERR_NONICKNAMEGIVEN}}

      assert response == Command.run(user, :nick)
    end

    @banned_nick "haxor"
    test "username is banned", %{user: user} do
      IRC.UserRegistry.ban(@banned_nick)
      response = {:error, {:ERR_UNAVAILRESOURCE, @banned_nick}}

      assert response == subject(user, {:nick, @banned_nick})
    end
  end
end
