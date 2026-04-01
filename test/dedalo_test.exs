defmodule DedaloTest do
  use ExUnit.Case
  doctest Dedalo

  test "greets the world" do
    assert Dedalo.hello() == :world
  end
end
