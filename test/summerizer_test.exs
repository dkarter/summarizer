defmodule SummerizerTest do
  use ExUnit.Case
  doctest Summerizer

  test "greets the world" do
    assert Summerizer.hello() == :world
  end
end
