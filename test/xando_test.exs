defmodule XandoTest do
  use ExUnit.Case
  doctest Xando

  test "greets the world" do
    assert Xando.hello() == :world
  end
end
