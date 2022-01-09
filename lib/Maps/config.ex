defmodule Maps.Config do
  defstruct [
    # Frame lat/long coordinates
    bottom: 0.0,
    left: 0.0,
    top: 0.0,
    right: 0.0,

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

  defp update_config(config, coord1, coord2, output_resolution) do
    [bottom, left] = parse_coords(coord1)
    [top, right] = parse_coords(coord2)

    config = %{config |
      bottom: bottom || config.bottom,
      left: left || config.left,
      top: top || config.top,
      right: right || config.right,
      output_resolution: output_resolution || config.output_resolution
    }
    config
  end

  defp parse_env(config) do
    update_config(
      config,
      Application.get_env(:maps, :coord1),
      Application.get_env(:maps, :coord2),
      Application.get_env(:maps, :output_resolution)
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

    IO.inspect(all_args)

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
      Keyword.get(args, :resolution)
    )
  end

  defp parse_output(config, args) when args == [], do: config
  defp parse_output(config, args) do
    [output | _ ] = args
    %{config | output: output}
  end

  def parse_frame(config) do
    [bottom, left] = parse_coords(Application.get_env(:maps, :coord1))
    [top, right] = parse_coords(Application.get_env(:maps, :coord2))

    %{config |
      bottom: bottom,
      left: left,
      top: top,
      right: right
    }
  end

  defp parse_coords(coords) when coords == nil, do: [nil, nil]
  defp parse_coords(coords) do
    for val <- String.split(coords, ",") do String.trim(val) end
  end


end
