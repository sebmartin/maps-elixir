defmodule Maps.Tile do
  alias Maps.Coordinate, as: Coord

  def longitude_to_km(longitude, latitude) do
    lat_r = latitude * Math.pi / 180.0
    111.320 * longitude * Math.cos(lat_r)
  end

  def latitude_to_km(latitude) do
    110.574 * latitude
  end

  def foreach(width_pixels, coord1, coord2, process_fn, context, x \\ 0, y \\ 0) do
    x_km = longitude_to_km(coord2.longitude - coord1.longitude, coord1.latitude)
    y_km = latitude_to_km(coord2.latitude - coord1.latitude)

    x_res = width_pixels
    y_res = trunc(x_res * y_km / x_km)

    cond do
      y_res > 1280 ->
        IO.puts("Slicing off top row")
        lat_tile_size = (1280.0 / y_res) * abs(coord2.latitude - coord1.latitude)

        # bottom row
        context = foreach(
          width_pixels,
          coord1,
          %Coord{
            latitude: Float.round(coord1.latitude + lat_tile_size, 7),
            longitude: coord2.longitude
          },
          process_fn,
          context,
          x, y
        )

        # remaining rows
        foreach(
          width_pixels,
          %Coord{
            latitude: Float.round(coord1.latitude + lat_tile_size, 7),
            longitude: coord1.longitude
          },
          coord2,
          process_fn,
          context,
          x, y + 1
        )

      x_res > 1280 ->
        IO.puts("Slicing left column")
        long_tile_size = (1280.0 / x_res) * abs(coord2.longitude - coord1.longitude)

        # left column
        context = foreach(
          1280,
          coord1,
          %Coord{
            latitude: coord2.latitude,
            longitude: Float.round(coord1.longitude + long_tile_size, 7)
          },
          process_fn,
          context,
          x, y
        )

        # remaining columns
        foreach(
          x_res - 1280,
          %Coord{
            latitude: coord1.latitude,
            longitude: Float.round(coord1.longitude + long_tile_size, 7)
          },
          coord2,
          process_fn,
          context,
          x + 1, y
        )

      true ->
        # IO.puts("Processing cell [#{x_res}, #{y_res}] at #{coord1.latitude}, #{coord1.longitude}, #{coord2.latitude}, #{coord2.longitude}")
        IO.puts("Processing cell (x: #{x}, y: #{y}), [#{x_res}, #{y_res}]")
        process_fn.(x, y, x_res, y_res, coord1, coord2, context)
    end
  end
end
