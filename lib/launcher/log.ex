defmodule Conconn.Launcher.Log do
  def persist_result(result, opts \\ []) do
    path = Keyword.get(opts, :path, "./results.txt")
    file = File.open!(path, [:append])
    date = DateTime.utc_now() |> DateTime.to_string()
    output = Kernel.inspect(result)
    if label = Keyword.get(opts, :label) do
      IO.puts(file, label)
    end
    IO.puts(file, "#{date}\n#{output}\n")
    File.close(file)
  end
end
