defmodule IRC.SessionRegistryTest do
  use ExUnit.Case, async: true

  @socket IO.stream(:stdio, :line)
  setup do
    {:ok, registry} = IRC.SessionRegistry.start_link([])
    %{registry: registry}
  end

  def create_session do
    {:ok, session} = IRC.Session.start_link([])
    session |> IRC.Session.attach_socket(@socket)
    {:ok, session}
  end

  describe "add/2, lookup/2" do
    test "lookup/2", %{registry: registry} do
      assert registry |> IRC.SessionRegistry.lookup(@socket) == :error
    end

    test "add/2", %{registry: registry} do
      {:ok, session} = create_session()

      IRC.SessionRegistry.add(registry, session)

      assert {:ok, session} == IRC.SessionRegistry.lookup(registry, @socket)
      assert {:ok, session} == IRC.SessionRegistry.lookup(registry, session)
    end
  end
end
