defmodule IRC.CommandTest do
  use ExUnit.Case, async: true
  doctest IRC.Command

  alias IRC.{UserRegistry, SessionRegistry, Session, Command}

  describe "run/1" do
    def subject(session, params) do
      Command.run(session, params)
    end

    @socket "123123213213"

    setup do
      {:ok, _} = SessionRegistry.start_link([name: SessionRegistry])
      SessionRegistry.create(@socket)
      {:ok, session} = SessionRegistry.lookup(@socket)
      {:ok, _} = UserRegistry.start_link([name: UserRegistry])
      %{session: session}
    end

    @long_nick "very_long_nick_name_here"
    @long_error_body {:ERR_ERRONEUSNICKNAME, @long_nick}
    test "long nickname", %{session: session} do
      assert {:error, @long_error_body} == subject(session, {:nick, @long_nick})
    end

    @short_nick "aa"
    @short_error_body {:ERR_ERRONEUSNICKNAME, @short_nick}
    test "short nickname", %{session: session} do
      response = {:error, @short_error_body}
      assert  response == subject(session, {:nick, @short_nick})
    end

    @used_nickname "voldemar"
    @user_nick_body {:ERR_NICKNAMEINUSE, @used_nickname}
    test "nickname in use", %{session: session} do
      UserRegistry.create(@used_nickname, Session.user(session))
      response = {:error, @user_nick_body}
      assert response == subject(session, {:nick, @used_nickname})
    end

    test "no enough params", %{session: session} do
      response = {:error, {:ERR_NONICKNAMEGIVEN}}

      assert response == Command.run(session, :nick)
    end

    @banned_nick "haxor"
    test "username is banned", %{session: session} do
      UserRegistry |> UserRegistry.ban(@banned_nick)
      response = {:error, {:ERR_UNAVAILRESOURCE, @banned_nick}}

      assert response == subject(session, {:nick, @banned_nick})
    end
  end
end
