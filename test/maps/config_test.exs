defmodule Maps.ConfigTest do
  use ExUnit.Case
  # doctest Maps.Config

  test "parse configs" do
    assert Maps.Config.parse([]) == %{}
  end
end
