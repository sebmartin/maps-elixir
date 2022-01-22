defmodule Maps.StitchTask do

  def start(coords, x, y, x_res, y_res, coord1, coord2) do
    Task.Supervisor.async(Maps.Stitcher, fn ->
      Maps.StitchTask.stitch(coords, x, y, x_res, y_res, coord1, coord2)
    end)
  end

  def stitch(coords, x, y, x_res, y_res, coord1, coord2) do
    message = "path [#{coords.lat}, #{coords.long}], #{x}, #{y}"
    IO.puts(message)
    IO.inspect([x, y, x_res, y_res, coord1, coord2])
    {:ok, message}
  end
end
