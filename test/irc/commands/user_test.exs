defmodule IRC.Commands.UserTest do
  use ExUnit.Case, async: true

  alias IRC.{UserRegistry}
  alias IRC.Commands.User

  describe "run/3" do
    def subject(user, login, mode, real_name) do
      user |> User.run(login, mode, real_name)
    end

    @nick "voldemar"

    setup do
      {:ok, user} = IRC.User.start_link([])
      {:ok, registry} = UserRegistry.start_link([])
      {:ok, user} = registry |> UserRegistry.create(@nick, user)

      %{user: user}
    end

    @login "voldemar"
    @mode 8
    @real_name "Voldemar Duletskiy"

    test "show welcome message", %{user: user} do
      response =
        [
          {:RPL_WELCOME, @nick, @login, "127.0.0.1"},
          :RPL_YOURHOST,
          :RPL_CREATED,
          :RPL_MYINFO
        ]

      assert user |> subject(@login, @mode, @real_name) == {:ok, response}
    end

    test "save user details" do
      {:ok, user} = IRC.User.start_link([])
      assert user |> subject(@login, @mode, @real_name) == :ok
    end
  end
end
