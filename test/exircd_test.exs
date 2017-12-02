defmodule ExIRCdTest do
  use ExUnit.Case
  doctest ExIRCd

  test "greets the world" do
    assert ExIRCd.hello() == :world
  end
end
