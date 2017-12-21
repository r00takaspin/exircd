defmodule UserRegistryTest do
  use ExUnit.Case, async: true

  alias IRC.UserRegistry

  setup do
    {:ok, registry} = UserRegistry.start_link([])
    %{registry: registry}
  end

  describe "lookup/1" do
    def subject(registry, nick) do UserRegistry.lookup(registry, nick)  end

    @nickname "test"
    test "return error if empty repository", %{registry: registry} do
      assert registry |> subject(@nickname) == :error
    end

    test "find existing nickname", %{registry: registry} do
      registry |> UserRegistry.create("test")
      {:ok, pid} = registry |> subject(@nickname)
      assert is_pid(pid)
    end
  end
end
