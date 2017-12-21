defmodule IRC.SessionTest do
  use ExUnit.Case, async: true

  alias IRC.{User, Session}

  setup do
    {:ok, session} = Session.start_link([])
    %{session: session}
  end

  describe "attach_socket/2, socket/1" do
    test "attach socket/2", %{session: session} do
      socket = IO.stream(:stdio, :line)
      session |> Session.attach_socket(socket)

      assert session |> Session.socket == socket
    end

    test "socket/1", %{session: session} do
      refute session |> Session.socket
    end
  end

  describe "attach_user/2, user/1" do
    test "attach user/2", %{session: session} do
      {:ok, user} = User.start_link([])
      session |> Session.attach_user(user)
      assert session |> Session.user == user
    end

    test "user/1", %{session: session} do
      refute session |> Session.user
    end
  end
end
