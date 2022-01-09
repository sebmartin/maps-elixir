defmodule Maps.CLI do
  def main(argv) do
    children = [
      {Task.Supervisor, name: Maps.Downloader},
      {Task.Supervisor, name: Maps.Stitcher},
    ]
    Supervisor.start_link(children, strategy: :one_for_one)

    config = Maps.Config.parse(argv)

    IO.inspect(config)

    download(config)
    stitch(config)
  end

  defp download(_config) do
    tasks = for x <- 1..4, y <- 1..4 do
      Maps.DownloadTask.start(%{lat: 1, long: 2}, x, y)
    end
    Task.await_many(tasks)
  end

  defp stitch(_config) do
    IO.puts("TODO: stitch")
  end
end
