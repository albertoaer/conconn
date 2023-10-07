defmodule Conconn.Launcher do
  alias Conconn.Launcher

  use Task

  def launch(client, task, count \\ 1) do
    async({client, task, count})
  end

  def launch(items) do
    async(items)
  end

  def await(launcher, timeout \\ :infinity) do
    Task.await(launcher, timeout)
  end

  def async(arg) do
    Task.async(__MODULE__, :run, [arg])
  end

  def run(opts) do
    {:ok, supervisor} = Launcher.Supervisor.start_link()
    count = perform_launch(opts, supervisor) |> length
    {:ok, results} = Launcher.Supervisor.start_child(supervisor, Conconn.ResultCollector)
    loop(results, count, 0)
  end

  def loop(results, count, received) when received >= count, do: Conconn.ResultCollector.summary(results)

  def loop(results, count, received) do
    receive do
      {:completed, metrics} ->
        Conconn.ResultCollector.put(results, metrics)
        loop(results, count, received + 1)
      :failure -> loop(results, count, received + 1)
    end
  end

  defp perform_launch({client, task, count}, supervisor) do
    for _ <- 0..count-1 do
      start_test_client_pair(client, task, supervisor)
    end
  end

  defp perform_launch(items, supervisor) when is_list(items), do: Enum.reduce(
    items, [], fn
      item, acc -> apply(&perform_launch/2, [item, supervisor]) ++ acc
    end
  )

  defp start_test_client_pair(client, task, supervisor) do
    {:ok, c_id} = Launcher.Supervisor.start_child(supervisor, client)
    {:ok, t_id} = Launcher.Supervisor.start_child(supervisor, task)
    Conconn.ConcTask.add_callback(t_id)
    Conconn.Client.begin_task(c_id, t_id)
  end
end
