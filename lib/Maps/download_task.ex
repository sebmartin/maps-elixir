defmodule Maps.DownloadTask do

  def download(supervisor, tmp_path, throttle, config) do
    tile_size = 512  # will download @2x so tiles will be 1024x1024
    Maps.Tile.foreach_tile(
      config.coord, config.radius, config.output_resolution,
      fn x, y, zoom, tile_corners ->
        create_task(supervisor, tmp_path, x, y, tile_corners, zoom, tile_size, config.mapbox_style, config.mapbox_access_token, throttle)
      end
    )
  end

  defp create_task(supervisor, basedir, x, y, tile_corners, zoom, tilesize, style, token, throttle) do
    Task.Supervisor.async(supervisor, fn ->
      :sleeplocks.execute(throttle, fn ->
        run_task(basedir, x, y, tile_corners, zoom, tilesize, style, token)
      end)
    end)
  end

  defp run_task(basedir, x, y, tile_corners, zoom, tilesize, style, token) do
    [cmd | args] = Maps.IO.mapbox_curl_command(basedir, x, y, zoom, tilesize, style, token)
    System.cmd(cmd, args, parallelism: true)

    # draw grid lines around tiles
    # tile = Maps.IO.local_tile_path(basedir, x, y)
    # System.cmd("convert", [tile, "-stroke", "black", "-strokewidth", "1", "-fill", "none", "-draw", "rectangle 0,0 1025,1025", tile])

    # crop outer tiles
    tile_size = 1024
    {x1, y1, x2, y2} = tile_corners
    crop_left = if x == trunc(x1), do: trunc((x1 - trunc(x1)) * tile_size), else: 0
    crop_bottom = if y == trunc(y1), do: trunc((1 - (y1 - trunc(y1))) * tile_size), else: 0
    crop_right = if x == trunc(x2), do: trunc((1 - (x2 - trunc(x2))) * tile_size), else: 0
    crop_top = if y == trunc(y2), do: trunc((y2 - trunc(y2)) * tile_size), else: 0

    crop_width = tile_size - crop_left - crop_right
    crop_height = tile_size - crop_top - crop_bottom

    IO.puts("Cropping #{x}x#{y} ==>  #{crop_width}x#{crop_height}+#{crop_left}+#{crop_top} (#{crop_right}, #{crop_bottom})")
    IO.inspect({x1, y1, x2, y2})
    IO.puts("-------")

    filepath = Maps.IO.local_tile_path(basedir, x, y)
    System.cmd("/usr/local/bin/convert", [filepath, "-crop", "#{crop_width}x#{crop_height}+#{crop_left}+#{crop_top}", filepath], parallelism: true)

    {:ok, cmd}
  end
end
