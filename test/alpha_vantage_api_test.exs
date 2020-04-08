defmodule AlphaVantageApiTest do
  use ExUnit.Case
  doctest AlphaVantageApi

  test "greets the world" do
    assert AlphaVantageApi.hello() == :world
  end
end
