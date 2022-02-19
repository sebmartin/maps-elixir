defmodule Maps.CLI do
  def main(argv) do
    children = [
      {Task.Supervisor, name: Maps.Downloader},
      {Task.Supervisor, name: Maps.Stitcher},
    ]
    Supervisor.start_link(children, strategy: :one_for_one)

    config = Maps.Config.parse(argv)
    if !config.output or config.output == "" do
      IO.puts("You must specify an output path with --output")
      exit(1)
    end

    if !config.mapbox_access_token or config.mapbox_access_token == "" do
      IO.puts("You must specify your MapBox access token with --token")
      exit(2)
    end

    IO.inspect(config)

    {output, tmp_path} = prepare_output(config.output)
    download(tmp_path, config)
    stitch_tiles(tmp_path, config)
    move_output(Maps.IO.local_final_path(tmp_path), output)
  end

  defp prepare_output(output) do
    output = Path.expand(output)
    File.mkdir_p!(Path.dirname(output))
    IO.puts("Will save final map to: #{output}")

    {:ok, tmp_path} = Temp.mkdir "elixir-maps"
    IO.puts("Using temporary path: #{tmp_path}")

    {output, tmp_path}
  end

  defp download(tmp_path, config) do
    IO.puts("Downloading tiles...")
    download_throttle_max = 20
    {:ok, download_throttle} = :sleeplocks.new(download_throttle_max)
    Task.await_many(
      Maps.DownloadTask.download(Maps.Downloader, tmp_path, download_throttle, config),
      120_000
    )
  end

  defp stitch_tiles(tmp_path, config) do
    IO.puts("Stitching tiles...")
    Task.await(
      Maps.StitchTask.stitch(Maps.Stitcher, tmp_path, config),
      120_000
    )
  end

  # defp crop_image(tmp_path, config) do
  #   # tiles are 1024px
  #   {{x1, y1}, {x2, y2}, _zoom} = Maps.Tile.tile_info(config.coord, config.radius, config.output_resolution)
  #   width = abs(trunc(x2) - trunc(x1)) * 1024
  #   height = abs(trunc(y2) - trunc(y1)) * 1024
  # end

  defp move_output(tmp_file, final_output) do
    File.cp!(tmp_file, final_output, fn _, _ -> true end)
    IO.puts("Final map complete: #{final_output}")
  end
end
