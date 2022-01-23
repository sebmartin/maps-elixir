defmodule Maps.DownloadTask do

  def download(supervisor, tmp_path, config) do
    task_launcher = fn x, y, x_res, y_res, coord1, coord2, context ->
      create_task(supervisor, tmp_path, x, y, x_res, y_res, coord1, coord2, config.mapbox_access_token, context)
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

  defp create_task(supervisor, basedir, x, y, x_res, y_res, coord1, coord2, token, context) do
    task = Task.Supervisor.async(supervisor, fn ->
      run_task(basedir, x, y, x_res, y_res, coord1, coord2, token)
    end)
    %{context | tasks: context.tasks ++ [task]}
  end

  defp run_task(basedir, x, y, x_res, y_res, coord1, coord2, token) do
    [cmd | args] = Maps.IO.mapbox_curl_command(basedir, x, y, x_res, y_res, coord1, coord2, token)
    System.cmd(cmd, args)
    {:ok, cmd}
  end
end
