defmodule Maps.StitchTask do
  def stitch(supervisor, basedir, config) do
    tile_info = collect_tile_info(basedir, config)

    Task.await_many(
      create_stitch_row_task(supervisor, tile_info.row_tiles, basedir)
    )

    create_stitch_final_task(supervisor, tile_info.columns, basedir)
  end

  defp collect_tile_info(basedir, config) do
    collect_info = fn x, y, _x_res, _y_res, _coord1, _coord2, context ->
      %{context |
        rows: max(context.rows, y + 1),
        columns: max(context.columns, x + 1),
        row_tiles: Map.put(context.row_tiles,
          y,
          Enum.sort(
            Map.get(context.row_tiles, y, []) ++ [Maps.IO.local_tile_path(basedir, x, y)]
          )
        )
      }
    end

    Maps.Tile.foreach(
      config.output_resolution,
      config.coord1,
      config.coord2,
      collect_info,
      %{
        rows: 0,
        columns: 0,
        row_tiles: %{}
      }
    )
  end

  defp create_stitch_row_task(supervisor, row_tiles, basedir) do
    Enum.map(row_tiles, fn {row, files} ->
      Task.Supervisor.async(supervisor, fn ->
        run_stitch_row_task(row, files, basedir)
      end)
    end)
  end

  defp run_stitch_row_task(row, files, basedir) do
    [cmd | args] = Maps.IO.stitch_row_command(row, Enum.sort(files), basedir)
    System.cmd(cmd, args)
  end

  defp create_stitch_final_task(supervisor, columns, basedir) do
    Task.Supervisor.async(supervisor, fn ->
      run_stitch_final_task(columns, basedir)
    end)
  end

  defp run_stitch_final_task(rows, basedir) do
    row_files = for row <- 0..(rows - 1), do: Maps.IO.local_row_path(basedir, row)
    [cmd | args] = Maps.IO.stitch_final_command(Enum.reverse(row_files), basedir)
    System.cmd(cmd, args)
  end

end
