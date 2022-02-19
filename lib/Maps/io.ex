defmodule Maps.IO do
	def local_tile_path(basedir, x, y) do
		x = x |> Integer.to_string |> String.pad_leading(3, "0")
		y = y |> Integer.to_string |> String.pad_leading(3, "0")
		"#{ basedir |> String.trim_trailing("/") }/tile.x#{x}.y#{y}.png"
	end

	def local_row_path(basedir, y) do
		y = y |> Integer.to_string |> String.pad_leading(3, "0")
		"#{ basedir |> String.trim_trailing("/") }/row.y#{y}.png"
	end

	def local_final_path(basedir) do
		"#{ basedir |> String.trim_trailing("/") }/map.png"
	end

	def mapbox_url(x, y, zoom, tilesize, style, token) do
		"https://api.mapbox.com/styles/v1/" <>
			"#{ style }/tiles/" <>
			"#{ tilesize }/" <>
			"#{ zoom }/#{ x }/#{ y }@2x" <>
			"?access_token=#{token}"
	end

	def mapbox_curl_command(basedir, x, y, zoom, tilesize, style, token) do
		[
			"curl", "--silent", "--show-error",
			"--output", Maps.IO.local_tile_path(basedir, x, y),
			mapbox_url(x, y, zoom, tilesize, style, token)
		]
	end

	def stitch_row_command(y, x_range, basedir) do
		output = local_row_path(basedir, y)
		tile_files = Enum.map(x_range, fn x ->
			local_tile_path(basedir, x, y)
		end)
		["convert", "+append"] ++ tile_files ++ [output]
	end

	def stitch_final_command(y_range, basedir) do
		row_files = for y <- y_range, do: Maps.IO.local_row_path(basedir, y)
		["convert", "-append"] ++ Enum.reverse(row_files) ++ [local_final_path(basedir)]
	end
end
