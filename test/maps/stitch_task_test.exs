defmodule Maps.StitchTaskTest do
  use ExUnit.Case
  alias Maps.Coordinate, as: Coord

  setup do
    %{
      config: %Maps.Config{
        coord1: %Coord{
          latitude: 44.95222,
          longitude: -76.37706,
        },
        coord2: %Coord{
          latitude: 45.60419,
          longitude: -75.13199,
        },
        output_resolution: 5000,
        output: "/tmp/final.png"
      }
    }
  end

  test "collect tile info", context do
    start_supervised({Task.Supervisor, name: Maps.TestStitcher})

    result = Maps.StitchTask.stitch(Maps.TestStitcher, "/tmp/foo", context.config)
    assert false
  end
end
