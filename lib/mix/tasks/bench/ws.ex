defmodule Mix.Tasks.Bench.Ws do
  use Mix.Task

  @impl Mix.Task
  def run(args) do
    task = Conconn.Launcher.launch(get_tasks(args))
    Conconn.Launcher.await(task) |> Kernel.inspect() |> Mix.Shell.IO.info()
  end

  def get_tasks(args) do
    {args, remain} = Enum.split_while(args, fn arg -> arg != "--" end)
    {flags, argv} = OptionParser.parse!(args, aliases: [t: :traffic, c: :clients], strict: [traffic: :integer, clients: :integer])
    url = extract_url(argv)
    task = {
      {
        Conconn.Client.WebSocket,
        url,
      },
      {
        Conconn.ConcTask.PingPongConcTask,
        traffic: Keyword.get(flags, :traffic, 1000),
      },
      Keyword.get(flags, :clients, 1)
    }
    case remain do
      [_ | remain] -> [task | get_tasks(remain)]
      _ -> [task]
    end
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
