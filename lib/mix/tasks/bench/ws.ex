defmodule Mix.Tasks.Bench.Ws do
  use Mix.Task

  @impl Mix.Task
  def run(args) do
    task = Conconn.Launcher.launch(get_tasks(args))
    Conconn.Launcher.await(task) |> Kernel.inspect() |> Mix.Shell.IO.info()
  end

  def get_tasks(args) do
    {args, remain} = Enum.split_while(args, fn arg -> arg != "--" end)
    {flags, argv} = OptionParser.parse!(
      args,
      aliases: [t: :traffic, c: :clients, v: :validation],
      strict: [traffic: :integer, clients: :integer, validation: :string]
    )
    url = extract_url(argv)
    task = {
      {
        Conconn.Client.WebSocket,
        url,
      },
      {
        extract_conc_task(Keyword.get(flags, :validation)),
        traffic: Keyword.get(flags, :traffic, 1000),
      },
      Keyword.get(flags, :clients, 1)
    }
    case remain do
      [_ | remain] -> [task | get_tasks(remain)]
      _ -> [task]
    end
  end

  def extract_conc_task(value) do
    case value do
      "emit" -> Conconn.ConcTask.EmitConcTask
      n when n in [nil, "echo"] -> Conconn.ConcTask.EchoConcTask
      n -> raise "Unknown concurrent task: #{n}"
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
