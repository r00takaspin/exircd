defmodule IRC.CommandTest do
  use ExUnit.Case, async: true
  doctest IRC.Command

  describe "run/1" do
    def subject(params) do
      IRC.Command.run(params)
    end

    setup do
      {:ok, _} = UserRegistry.start_link([name: UserRegistry])
      :ok
    end

    @long_nick "very_long_nick_name_here"
    @long_error_body {:ERR_ERRONEUSNICKNAME, @long_nick}
    test "long nickname" do
      assert {:error, @long_error_body} == subject({:nick, @long_nick})
    end

    @short_nick "aa"
    @short_error_body {:ERR_ERRONEUSNICKNAME, @short_nick}
    test "short nickname" do
      assert {:error, @short_error_body} == subject({:nick, @short_nick})
    end
  end
end
