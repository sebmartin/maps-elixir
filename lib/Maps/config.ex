defmodule Maps.Config do
  alias Maps.Coordinate, as: Coord
  defstruct [
    # Frame lat/long coordinates
    coord1: %Maps.Coordinate{},
    coord2: %Maps.Coordinate{},

    output: nil,
    output_resolution: 1280,
    columns: 1,
    rows: 1,

    mapbox_access_token: ""
  ]

  def parse(argv) do
    %Maps.Config{}
    |> parse_env
    |> parse_argv(argv)
  end

  defp update_config(config, coord1, coord2, output_resolution, token) do
    coord1 = Maps.Coordinate.parse_string(coord1)
    coord2 = Maps.Coordinate.parse_string(coord2)

    [bottom, top] = Enum.sort([coord1.latitude, coord2.latitude])
    [left, right] = Enum.sort([coord1.longitude, coord2.longitude])

    config = %{config |
      coord1: %Coord{
        latitude: bottom || config.coord1.latitude,
        longitude: left || config.coord1.longitude,
      },
      coord2: %Coord{
        latitude: top || config.coord2.latitude,
        longitude: right || config.coord2.longitude,
      },
      output_resolution: output_resolution || config.output_resolution,
      mapbox_access_token: token || config.mapbox_access_token,
    }
    config
  end

  defp parse_env(config) do
    update_config(
      config,
      Application.get_env(:maps, :coord1),
      Application.get_env(:maps, :coord2),
      Application.get_env(:maps, :output_resolution),
      nil
    )
  end

  defp parse_argv(config, argv) do
    all_args = OptionParser.parse(
      argv,
      strict: [
        coord1: :string,
        coord2: :string,
        resolution: :integer,
        config: :string,
        token: :string
      ],
      aliases: [
        c: :coord1,
        d: :coord2,
        r: :resolution,
        f: :config,
        t: :token
      ]
    )
    {parsed, args, _invalid} = all_args

    config = config
    |> parse_config_file(parsed)
    |> parse_cli_args(parsed)
    |> parse_output(args)

    config
  end

  defp parse_config_file(config, args) do
    unless :config in Keyword.keys(args) do
      config
    end
    # TODO parse yaml config
    config
  end

  defp parse_cli_args(config, args) do
    # TODO add validation
    update_config(
      config,
      Keyword.get(args, :coord1),
      Keyword.get(args, :coord2),
      Keyword.get(args, :resolution),
      Keyword.get(args, :token)
    )
  end

  defp parse_output(config, args) when args == [], do: config
  defp parse_output(config, args) do
    [output | _ ] = args
    %{config | output: output}
  end
end
