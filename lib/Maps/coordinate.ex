defmodule Maps.Coordinate do
  defstruct [
    latitude: 0.0,
    longitude: 0.0
  ]

  def parse_string(coords) when coords == nil, do: %Maps.Coordinate{
    latitude: nil, longitude: nil
  }
  def parse_string(coords) do
    [lat, long] = for val <- String.split(coords, ",") do
      String.trim(val) |> String.to_float
    end
    %Maps.Coordinate{
      latitude: lat,
      longitude: long
    }
  end
end
