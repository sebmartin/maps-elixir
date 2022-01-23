defmodule Maps.DownloadTask do

  def start(basedir, x, y, x_res, y_res, coord1, coord2, token, context) do
    task = Task.Supervisor.async(Maps.Downloader, fn ->
      Maps.DownloadTask.download(basedir, x, y, x_res, y_res, coord1, coord2, token)
    end)
    %{context | tasks: context.tasks ++ [task]}
  end

  def download(basedir, x, y, x_res, y_res, coord1, coord2, token) do
    [cmd | args] = Maps.IO.mapbox_curl_command(basedir, x, y, x_res, y_res, coord1, coord2, token)
    System.cmd(cmd, args)
    {:ok, cmd}
  end
end
