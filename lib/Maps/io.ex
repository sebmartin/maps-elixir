defmodule Maps.IO do
	def local_tile_path(basedir, x, y) do
		x = x |> Integer.to_string |> String.pad_leading(3, "0")
		y = y |> Integer.to_string |> String.pad_leading(3, "0")
		"#{ basedir |> String.trim_trailing("/") }/tile.x#{x}.y#{y}.png"
	end

	def local_row_path(basedir, row) do
		y = row |> Integer.to_string |> String.pad_leading(3, "0")
		"#{ basedir |> String.trim_trailing("/") }/row.y#{y}.png"
	end

	def local_final_path(basedir) do
		"#{ basedir |> String.trim_trailing("/") }/map.png"
	end

	def mapbox_url(x_res, y_res, coord1, coord2, token, map \\ "outdoors-v11") do
		coord_string = fn coord1, coord2 ->
			"#{coord1.longitude},#{coord1.latitude},#{coord2.longitude},#{coord2.latitude}"
		end
		"https://api.mapbox.com/styles/v1/mapbox/" <>
			"#{ map }/static/" <>
			"%5B#{ coord_string.(coord1, coord2) }%5D" <>
			"/#{ x_res }x#{ y_res }" <>
			"?access_token=#{token}" <>
			"&attribution=false&logo=false"
	end

	def mapbox_curl_command(basedir, x, y, x_res, y_res, coord1, coord2, token, map \\ "outdoors-v11") do
		[
			"curl", "--silent", "--show-error",
			"--output", Maps.IO.local_tile_path(basedir, x, y),
			mapbox_url(x_res, y_res, coord1, coord2, token, map)
		]
	end

	def stitch_row_command(row, tile_files, basedir) do
		output = local_row_path(basedir, row)
		["convert", "+append"] ++ tile_files ++ [output]
	end

	def stitch_final_command(row_files, basedir) do
		["convert", "-append"] ++ row_files ++ [local_final_path(basedir)]
	end
end
