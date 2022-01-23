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

    {:ok, tmp_path} = Temp.mkdir "elixir-maps"
    IO.puts("Using temporary path: #{tmp_path}")

    tasks = download(tmp_path, config)
    Task.await_many(tasks)
    stitch(config)
  end

  defp download(tmp_path, config) do
    task_launcher = fn x, y, x_res, y_res, coord1, coord2, context ->
      Maps.DownloadTask.start(tmp_path, x, y, x_res, y_res, coord1, coord2, config.mapbox_access_token, context)
    end
    context = Maps.Tile.foreach(
      config.output_resolution,
      config.coord1,
      config.coord2,
      task_launcher,
      %{
        tasks: []
      }
    )
    context.tasks
  end

  defp stitch(_config) do
    IO.puts("TODO: stitch")
  end
end
