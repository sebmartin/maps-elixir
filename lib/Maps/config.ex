defmodule Maps.Config do
  alias Maps.Coordinate, as: Coord
  defstruct [
    # Frame lat/long coordinates
    coord: %Coord{},
    radius: 1.0,

    output: nil,
    output_resolution: 1280,
    columns: 1,
    rows: 1,

    mapbox_access_token: "",
    mapbox_style: "mapbox/outdoors-v11"
  ]

  def parse(argv) do
    %Maps.Config{}
    |> parse_env
    |> parse_argv(argv)
  end

  defp update_config(config, coord, radius, output_resolution, style, token) do
    %{config |
      coord: Coord.parse_string(coord),
      radius: radius,
      output_resolution: output_resolution || config.output_resolution,
      mapbox_style: style || config.mapbox_style,
      mapbox_access_token: token || config.mapbox_access_token
    }
  end

  defp parse_env(config) do
    update_config(
      config,
      Application.get_env(:maps, :coord),
      Application.get_env(:maps, :coord2),
      Application.get_env(:maps, :output_resolution),
      Application.get_env(:maps, :style),
      nil  # discourage storing the token in the env
    )
  end

  defp parse_argv(config, argv) do
    all_args = OptionParser.parse(
      argv,
      strict: [
        coord: :string,
        radius: :float,
        resolution: :integer,
        config: :string,
        token: :string,
        style: :string
      ],
      aliases: [
        c: :coord,
        r: :radius,
        w: :resolution,
        f: :config,
        t: :token,
        s: :style
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
      Keyword.get(args, :coord),
      Keyword.get(args, :radius),
      Keyword.get(args, :resolution),
      Keyword.get(args, :style),
      Keyword.get(args, :token)
    )
  end

  defp parse_output(config, args) when args == [], do: config
  defp parse_output(config, args) do
    [output | _ ] = args
    %{config | output: output}
  end
end
