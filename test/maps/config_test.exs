defmodule Maps.ConfigTest do
  use ExUnit.Case
  # doctest Maps.Config

  setup %{} do
    %{
      config_env: %Maps.Config{
        bottom: "44.95222",
        left: "-76.37706",
        top: "45.60419",
        right: "-75.13199",
        columns: 1,
        rows: 1,
        mapbox_access_token: "",
        output: nil,
        output_resolution: 6400,
      }
    }
  end

  test "parse env configs", context do
    assert Maps.Config.parse([]) == context[:config_env]
  end

  test "parse with only output argument", context do
    expected = %{context[:config_env] | output: "/output/path"}
    assert Maps.Config.parse(["/output/path"]) == expected
  end

  test "parse external config yaml file", context do
    # TODO write arguments to temp yaml
    expected = %{context[:config_env] |
      bottom: "12.3456",
      left: "-76.5432",
      top: "13.3456",
      right: "-77.5432",
      output: "/output/path",
      output_resolution: 10000,
      mapbox_access_token: "super_secret_magical_token",
    }
    assert Maps.Config.parse(["-f arguments.yaml /output/path"]) == expected
  end

  test "parse cli overrides using aliases", context do
    argsv = [
      "-c", "12.3456, -76.5432",
      "-d", "13.3456, -77.5432",
      "-r", "10000",
      "-t", "super_secret_magical_token",
      "/output/path"
    ]
    expected = %{context[:config_env] |
      bottom: "12.3456",
      left: "-76.5432",
      top: "13.3456",
      right: "-77.5432",
      output: "/output/path",
      output_resolution: 10000,
      mapbox_access_token: "super_secret_magical_token",
    }
    assert Maps.Config.parse(argsv) == expected
  end

  test "parse cli overrides using full argument names", context do
    argsv = [
      "--coord1", "12.3456, -76.5432",
      "--coord2", "13.3456, -77.5432",
      "--resolution", "10000",
      "--token", "super_secret_magical_token",
      "/output/path"
    ]
    expected = %{context[:config_env] |
      bottom: "12.3456",
      left: "-76.5432",
      top: "13.3456",
      right: "-77.5432",
      output: "/output/path",
      output_resolution: 10000,
      mapbox_access_token: "super_secret_magical_token",
    }
    assert Maps.Config.parse(argsv) == expected
  end

  test "parse coordinates are always changed to bottom-left and top-right corners", context do
    top_left = "20.0, -20.0"
    bottom_right = "10.0, -10.0"
    argsv = [
      "-c", top_left,
      "-d", bottom_right
    ]
    expected = %{context[:config_env] |
      bottom: "10.0",
      left: "-20.0",
      top: "20.0",
      right: "-10.0",
    }
    assert Maps.Config.parse(argsv) == expected
  end

  test "parse coordinates can be swapped", context do
    bottom_left = "10.0, -20.0"
    top_right = "20.0, -10.0"
    expected = %{context[:config_env] |
      bottom: "10.0",
      left: "-20.0",
      top: "20.0",
      right: "-10.0",
    }
    assert Maps.Config.parse(["-c", top_right, "-d", bottom_left]) == expected
    assert Maps.Config.parse(["-c", bottom_left, "-d", top_right]) == expected
  end
end
