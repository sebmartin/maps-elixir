defmodule Maps.DownloadTask do

  def start(coords, x, y) do
    Task.Supervisor.async(Maps.Downloader, fn ->
      Maps.DownloadTask.download(coords, x, y)
    end)
  end

  @spec download(Map, Integer, Integer) :: {:ok, String.any}
  def download(coords, x, y) do
    message = "path [#{coords.lat}, #{coords.long}], #{x}, #{y}"
    IO.puts(message)
    {:ok, message}
  end
end
