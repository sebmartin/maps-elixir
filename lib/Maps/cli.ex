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

    IO.puts("Downloading tiles...")
    Task.await_many(
      Maps.DownloadTask.download(Maps.Downloader, tmp_path, config)
    )

    IO.puts("Stitching tiles...")
    Task.await(
      Maps.StitchTask.stitch(Maps.Stitcher, tmp_path, config)
    )

    IO.puts("Final map complete: #{Maps.IO.local_final_path(tmp_path)}")
  end
end
