defmodule Conconn.Launcher.Log do
  def persist_result(result, path \\ "./results.txt") do
    file = File.open!(path, [:append])
    date = DateTime.utc_now() |> DateTime.to_string()
    output = Kernel.inspect(result)
    IO.puts(file, "#{date}\n#{output}\n")
    File.close(file)
  end
end
