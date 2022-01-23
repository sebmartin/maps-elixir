defmodule Maps.IOTest do
  use ExUnit.Case
  alias Maps.Coordinate, as: Coord

  test "local tile path handles trailing slashes" do
    result = Maps.IO.local_tile_path(
      "/tmp/something///",
      1, 2
    )
    assert result == "/tmp/something/tile.x001.y002.png"
  end

  test "mapbox url with explicit map" do
    result = Maps.IO.mapbox_url(
      1280, 942,
      %Coord{
        latitude: 44.95222,
        longitude: -76.37706,
      },
      %Coord{
        latitude: 45.60419,
        longitude: -75.13199,
      },
      "super-secret-token",
      "satellite-v9"
    )
    assert result == "https://api.mapbox.com/styles/v1/mapbox/" <>
      "satellite-v9/static/" <>
      "%5B-76.37706,44.95222,-75.13199,45.60419%5D" <>
      "/1280x942" <>
      "?access_token=super-secret-token&attribution=false&logo=false"
  end

  test "mapbox url with default map (defaults to outdoors map)" do
    result = Maps.IO.mapbox_url(
      1280, 942,
      %Coord{
        latitude: 44.95222,
        longitude: -76.37706,
      },
      %Coord{
        latitude: 45.60419,
        longitude: -75.13199,
      },
      "super-secret-token"
    )
    assert result == "https://api.mapbox.com/styles/v1/mapbox/" <>
      "outdoors-v11/static/" <>
      "%5B-76.37706,44.95222,-75.13199,45.60419%5D" <>
      "/1280x942" <>
      "?access_token=super-secret-token&attribution=false&logo=false"
  end
end
