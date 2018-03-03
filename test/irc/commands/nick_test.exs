defmodule IRC.Commands.NickTest do
  use ExUnit.Case, async: true

  alias IRC.{UserRegistry, SessionRegistry, Commands.Nick}

  describe "run/3" do
    def subject(nick, session, user_registry) do
      Nick.run(nick, session, user_registry)
    end

    @socket "123213213"

    setup do
      {:ok, _} = SessionRegistry.start_link([name: SessionRegistry])
      SessionRegistry.create(@socket)
      {:ok, session} = SessionRegistry.lookup(@socket)
      {:ok, registry} = UserRegistry.start_link([])
      %{session: session, registry: registry}
    end

    @long_nick "very_long_nick_name_here"
    test "long nickname: #{@long_nick}", context do
      %{session: session, registry: registry} = context

      body = {:error, {:ERR_ERRONEUSNICKNAME, @long_nick}}
      assert body == subject(@long_nick, session, registry)
    end

    @short_nick "aa"
    test "short nickname: #{@short_nick}", context do
      %{session: session, registry: registry} = context
      body = {:error, {:ERR_ERRONEUSNICKNAME, @short_nick}}
      assert  body == subject(@short_nick, session, registry)
    end

    @used_nickname "voldemar"
    test "nickname in use: #{@used_nickname}", context do
      %{session: session, registry: registry} = context
      {:ok, user} = IRC.User.start_link([])

      registry |> UserRegistry.create(@used_nickname, user)
      response = {:error, {:ERR_NICKNAMEINUSE, @used_nickname}}
      assert response == subject(@used_nickname, session, registry)
    end

    test "session has attached user", context do
      %{session: session, registry: registry} = context
      poopa = "poopa"
      loopa = "loopa"

      assert :ok == subject(loopa, session, registry)
      assert :ok == subject(poopa, session, registry)
    end

    test "register valid user", context do
      %{session: session, registry: registry} = context
      assert :ok == subject("valid_nick", session, registry)
    end

    @banned_nickname "loopa"
    test "banned nickname: #{@banned_nickname}", context do
      %{session: session, registry: registry} = context
      registry |> UserRegistry.ban(@banned_nickname)
      response = {:error, {:ERR_UNAVAILRESOURCE, @banned_nickname}}
      assert response == subject(@banned_nickname, session, registry)
    end
  end
end
