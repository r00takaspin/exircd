defmodule IRC.CommandTest do
  use ExUnit.Case, async: true
  doctest IRC.Command

  alias IRC.{UserRegistry, Session, Command}

  describe "run/1" do
    def subject(session, params) do
      Command.run(session, params)
    end

    setup do
      session = Session.start_link([])
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
      UserRegistry.create(@used_nickname)
      response = {:error, @user_nick_body}
      assert response == subject(session, {:nick, @used_nickname})
    end
  end
end
