defmodule Mix.Tasks.Bench.Ws do
  use Mix.Task

  @impl Mix.Task
  def run(args) do
    {flags, argv} = OptionParser.parse!(args, strict: [traffic: :integer, clients: :integer])
    url = extract_url(argv)
    task = Conconn.Client.WebSocket.launch(
      url,
      {
        Conconn.ConcTask.PingPongConcTask,
        traffic: Keyword.get(flags, :traffic, 1000),
      },
      Keyword.get(flags, :clients, 1)
    )
    Conconn.Launcher.await(task) |> Kernel.inspect() |> Mix.Shell.IO.info()
  end

  def extract_url(argv) do
    try do
      [url] = argv
      url
    rescue
      _ -> reraise "Expecting only an argument, the url", __STACKTRACE__
    end
  end
end
