defmodule Maps.TileTest do
  alias Maps.Coordinate, as: Coord
  use ExUnit.Case

  setup do
    %{
      process_fn: fn (x, y, x_res, y_res, coord1, coord2, context) ->
        Map.merge(context, %{[x, y] => [x_res: x_res, y_res: y_res, coord1: coord1, coord2: coord2]})
      end,
      width: 5000,
      coord1: %Coord{
        latitude: 44.95222,
        longitude: -76.37706,
      },
      coord2: %Coord{
        latitude: 45.60419,
        longitude: -75.13199,
      }
    }
  end

  def foreach_tile(args, context \\ %{}) do
    Maps.Tile.foreach(args[:width], args[:coord1], args[:coord2], args[:process_fn], context)
  end

  test "each row of tiles has the same total pixel width", context do
    result = foreach_tile(context)

    widths = for y <- 0..2, do: for x <- 0..3, do: result[[x,y]][:x_res]
    widths_summed = for w <- widths, do: Enum.sum(w)
    expected_width = context[:width]
    assert Enum.all?(widths_summed, fn x -> x == expected_width end)
  end

  test "each row of tiles add up to the correct longitude", context do
    result = foreach_tile(context)

    widths = for y <- 0..2, do: for x <- 0..3, do: result[[x,y]][:coord2].longitude - result[[x,y]][:coord1].longitude
    widths_summed = for w <- widths, do: Enum.sum(w)
    expected_long_diff = context[:coord2].longitude - context[:coord1].longitude
    assert Enum.all?(widths_summed, fn x -> x == expected_long_diff end)
  end

  test "each column of tiles has the same total pixel height", context do
    result = foreach_tile(context)

    heights = for x <- 0..3, do: for y <- 0..2, do: result[[x,y]][:y_res]
    IO.inspect(heights)
    heights_summed = for w <- heights, do: Enum.sum(w)
    expected_height = 3688
    assert Enum.all?(heights_summed, fn x -> x == expected_height end)
  end

  test "each column of tiles add up to the correct latitude", context do
    result = foreach_tile(context)

    heights = for x <- 0..3, do: for y <- 0..2, do: result[[x,y]][:coord2].latitude - result[[x,y]][:coord1].latitude
    heights_summed = for w <- heights, do: Enum.sum(w)
    expected_long_diff = context[:coord2].latitude - context[:coord1].latitude
    assert Enum.all?(heights_summed, fn x -> x == expected_long_diff end)
  end

  test "the context is always appended", context do
    map = %{starting_value: "start"}
    result = foreach_tile(context, map)

    %{starting_value: x} = map
    assert x == "start"
  end
end
