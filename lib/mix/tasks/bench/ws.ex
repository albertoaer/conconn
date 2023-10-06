defmodule Mix.Tasks.Bench.Ws do
  use Mix.Task

  @impl Mix.Task
  def run(args) when length(args) > 0 do
    task = Conconn.Client.WebSocket.launch(
      Enum.at(args, 0),
      {
        Conconn.ConcTask.PingPongConcTask,
        traffic: Enum.at(args, 1, 1000),
      }
    )
    Conconn.Launcher.await(task)
  end
end
