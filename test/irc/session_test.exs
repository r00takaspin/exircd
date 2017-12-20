defmodule IRC.SessionTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, session} = IRC.Session.start_link([])
    %{session: session}
  end

  describe "attach_socket/2, socket/1" do
    test "attach socket/2", %{session: session} do
      socket = IO.stream(:stdio, :line)
      session |> IRC.Session.attach_socket(socket)

      assert session |> IRC.Session.socket == socket
    end

    test "socket/1", %{session: session} do
      refute session |> IRC.Session.socket
    end
  end

  describe "attach_user/2, user/1" do
    test "attach user/2", %{session: session} do
      {:ok, user} = User.start_link([])
      session |> IRC.Session.attach_user(user)
      assert session |> IRC.Session.user == user
    end

    test "user/1", %{session: session} do
      refute session |> IRC.Session.user
    end
  end
end
