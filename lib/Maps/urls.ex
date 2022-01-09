defmodule Maps.Urls do
	def coords(config) do
		deltas = %{
			# TODO calculate this
			long: 0.0,
			lat: 0.0
		}
		for x <- 1..config.columns,
		y <- 1..config.rows,
		do: %{
			left: Float.round(config.left + (x-1) * deltas.long, 6),
			bottom: Float.round(config.bottom + (y-1) * deltas.lat, 6),
			right: Float.round(config.left + (x) * deltas.long, 6),
			top: Float.round(config.bottom + (y) * deltas.lat, 6),
			x: x,
			y: y
		}
	end

	defp coord_url_string(coords) do
		"#{coords.left},#{coords.bottom},#{coords.right},#{coords.top}"
	end

	def urls(config) do
		for coords <- Maps.Urls.coords(config),
				coord_str = coord_url_string(coords),
				do: %{
					url: "https://api.mapbox.com/styles/v1/mapbox/outdoors-v11/static/%5B#{coord_str}%5D/1280x1280?access_token=#{config.mapbox_access_token}&attribution=false&logo=false",
					x: coords.x,
					y: coords.y
				}
	end

	def curl_commands(config) do
		for url <- Maps.Urls.urls(config),
				%{url: url, x: x, y: y} = url,
				do: "curl -so image_#{x}_#{y}.png #{url}"
	end
end
