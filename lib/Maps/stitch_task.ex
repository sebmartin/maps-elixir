defmodule Maps.StitchTask do
  def stitch(supervisor, basedir, config) do
    {{x1, y1}, {x2, y2}, _zoom} = Maps.Tile.tile_info(config.coord, config.radius, config.output_resolution)

    Task.await_many(
      create_stitch_row_task(supervisor, x1..x2, y1..y2, basedir),
      120_000
    )

    create_stitch_final_task(supervisor, y1..y2, basedir)
  end

  defp create_stitch_row_task(supervisor, x_range, y_range, basedir) do
    Enum.map(y_range, fn y ->
      Task.Supervisor.async(supervisor, fn ->
        run_stitch_row_task(y, x_range, basedir)
      end)
    end)
  end

  defp run_stitch_row_task(y, x_range, basedir) do
    [cmd | args] = Maps.IO.stitch_row_command(y, x_range, basedir)
    System.cmd(cmd, args)
  end

  defp create_stitch_final_task(supervisor, y_range, basedir) do
    Task.Supervisor.async(supervisor, fn ->
      run_stitch_final_task(y_range, basedir)
    end)
  end

  defp run_stitch_final_task(y_range, basedir) do
    [cmd | args] = Maps.IO.stitch_final_command(y_range, basedir)
    System.cmd(cmd, args)
  end

end
