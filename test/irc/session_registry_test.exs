defmodule IRC.SessionRegistryTest do
  use ExUnit.Case, async: true

  @socket IO.stream(:stdio, :line)
  setup do
    {:ok, registry} = IRC.SessionRegistry.start_link([])
    %{registry: registry}
  end

  test "lookup/2", %{registry: registry} do
    assert registry |> IRC.SessionRegistry.lookup(@socket) == :error
  end

  test "create/2", %{registry: registry} do
    IRC.SessionRegistry.create(registry, @socket)
    {:ok, session} = IRC.SessionRegistry.lookup(registry, @socket)
    assert session |> IRC.Session.socket == @socket
  end
end
