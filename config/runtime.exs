import Config

case config_env() do
  :prod ->
    # coords expected in format "{lat}, {long}"
    config :maps, :coord1, "0.0000, 0.0000"
    config :maps, :coord2, "0.0000, 0.0000"
    config :maps, :output_resolution, 1280

  :dev ->
    config :maps, :coord1, "44.95222, -76.37706"
    config :maps, :coord2, "45.60419, -75.13199"
    config :maps, :output_resolution, 6400

  :test ->
    config :maps, :coord1, "44.95222, -76.37706"
    config :maps, :coord2, "45.60419, -75.13199"
    config :maps, :output_resolution, 6400
end
