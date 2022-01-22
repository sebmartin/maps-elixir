defmodule Maps.Coordinate do
  defstruct [
    latitude: 0.0,
    longitude: 0.0
  ]

  def parse_string(coords) when coords == nil, do: [nil, nil]
  def parse_string(coords) do
    for val <- String.split(coords, ",") do
      String.trim(val) |> String.to_float
    end
  end
end
