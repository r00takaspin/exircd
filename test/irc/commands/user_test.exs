defmodule IRC.Commands.UserTest do
  use ExUnit.Case

  alias IRC.{Commands.User, Support.Factory}

  setup_all do
    {:ok, _} = Registry.start_link(keys: :unique, name: UserRegistry)
    :ok
  end

  describe "run/3" do
    def subject(user, login, mode, real_name) do
      user |> User.run(login, mode, real_name)
    end

    @nick "voldemar"

    setup do
      {:ok, user} = Factory.user()
      %{user: user}
    end

    @login "voldemar"
    @mode 8
    @real_name "Voldemar Duletskiy"

    test "show welcome message", %{user: user} do
      IRC.User.nick(user, @nick)

      response =
        [
          {:RPL_WELCOME, @nick, @login, "127.0.0.1"},
          {:RPL_YOURHOST, @nick},
          {:RPL_CREATED, @nick},
          {:RPL_MYINFO, @nick}
        ]

      assert IRC.User.info(user) |> subject(@login, @mode, @real_name) == {:ok, response}
    end

    test "save user details", %{user: user} do
      assert IRC.User.info(user) |> subject(@login, @mode, @real_name) == :ok
    end
  end
end
