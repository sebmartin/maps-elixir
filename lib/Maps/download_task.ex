defmodule Maps.DownloadTask do

  def start(coords, x, y, x_res, y_res, coord1, coord2) do
    Task.Supervisor.async(Maps.Downloader, fn ->
      Maps.DownloadTask.download(coords, x, y, x_res, y_res, coord1, coord2)
    end)
  end

  def download(coords, x, y, x_res, y_res, coord1, coord2) do
    message = "path [#{coords.lat}, #{coords.long}], #{x}, #{y}"
    IO.puts(message)
    IO.inspect([x, y, x_res, y_res, coord1, coord2])
    {:ok, message}
  end
end
