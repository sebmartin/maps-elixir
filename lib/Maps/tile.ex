defmodule Maps.Tile do
  alias Maps.Coordinate, as: Coord

  def longitude_to_km(longitude, latitude) do
    lat_r = latitude * Math.pi / 180.0
    111.320 * longitude * Math.cos(lat_r)
  end

  def latitude_to_km(latitude) do
    110.574 * latitude
  end

  def km_to_longitude(km, latitude) do
    lat_r = latitude * Math.pi / 180.0
    km / (111.320 * Math.cos(lat_r))
  end

  def km_to_latitude(km) do
    km / 110.574
  end

  def zoomlevel(meters_per_pixel, latitude) do
    circ_earth = 40_075_016.686  # equatorial circumference of the Earth in meters
    lat_r = latitude * Math.pi / 180.0
    zoom = Math.log(circ_earth * Math.cos(lat_r) / meters_per_pixel) / Math.log(2) - 9 # 9 for 2^9 == 512 (tile size)
    IO.puts("Actual zoom: #{zoom}")
    trunc(zoom)
  end

  def latitude_to_tile_y(latitude, zoom, truncate \\ True) do
    n = Math.pow(2, zoom)
    lat_r = latitude * Math.pi / 180.0
    y = n * (1 - (Math.log(Math.tan(lat_r) + 1.0/Math.cos(lat_r)) / Math.pi)) / 2
    if truncate == True, do: trunc(y), else: y
  end

  def longitude_to_tile_x(longitude, zoom, truncate \\ True) do
    n = Math.pow(2, zoom)
    x = n * ((longitude + 180) / 360.0)
    if truncate == True, do: trunc(x), else: x
  end

  def tiles_for_coordinate(coord, zoomlevel, truncate \\ True) do
    {
      longitude_to_tile_x(coord.longitude, zoomlevel, truncate),
      latitude_to_tile_y(coord.latitude, zoomlevel, truncate)
    }
  end

  def tile_info(coord, radius, resolution, truncate \\ True) do
    radius_x_deg = Maps.Tile.km_to_longitude(radius / 1000.0, coord.latitude)
    radius_y_deg = Maps.Tile.km_to_latitude(radius / 1000.0)

    coord1 = %Coord{
      latitude: coord.latitude - radius_y_deg,
      longitude: coord.longitude - radius_x_deg
    }
    coord2 = %Coord{
      latitude: coord.latitude + radius_y_deg,
      longitude: coord.longitude + radius_x_deg
    }

    diameter = radius * 2.0
    meters_per_pixel = diameter / resolution
    zoom = Maps.Tile.zoomlevel(meters_per_pixel, coord.latitude)

    {x1, y1} = Maps.Tile.tiles_for_coordinate(coord1, zoom, truncate)
    {x2, y2} = Maps.Tile.tiles_for_coordinate(coord2, zoom, truncate)

    {{x1, y1}, {x2, y2}, zoom}
  end

  @spec foreach_tile(
          atom | %{:latitude => number, :longitude => number, optional(any) => any},
          number,
          number,
          any
        ) :: list
  def foreach_tile(coord, radius, resolution, process_fn) do
    {{x1, y1}, {x2, y2}, zoom} = tile_info(coord, radius, resolution, False)

    for x <- trunc(x1)..trunc(x2), y <- trunc(y1)..trunc(y2) do
      process_fn.(x, y, zoom, {x1, y1, x2, y2})
    end
  end
end
