defmodule SpooksTest do
  use ExUnit.Case
  doctest Spooks

  test "greets the world" do
    assert Spooks.hello() == :world
  end
end
