defmodule Conconn.Launcher.Group do
  @spec launch_group({term, term, integer}, pid, pid, term) :: :ok
  def launch_group({client, task, count}, supervisor, results, group) do
    {:ok, supervisor} = Conconn.Launcher.Supervisor.start_child(supervisor, Conconn.Launcher.Supervisor)
    perform_launch(client, task, count, supervisor)
    loop(group, results, count, 0)
  end

  def loop(group, results, count, received) when received >= count, do: Conconn.ResultCollector.summary(results, group)

  def loop(group, results, count, received) do
    receive do
      {:completed, metrics} ->
        Conconn.ResultCollector.put(results, metrics, group)
        loop(group, results, count, received + 1)
      :failure -> loop(group, results, count, received + 1)
    end
  end

  defp perform_launch(client, task, count, supervisor) do
    for _ <- 0..count-1 do
      start_test_client_pair(client, task, supervisor)
    end
  end

  defp start_test_client_pair(client, task, supervisor) do
    {:ok, c_id} = Conconn.Launcher.Supervisor.start_child(supervisor, client)
    {:ok, t_id} = Conconn.Launcher.Supervisor.start_child(supervisor, task)
    Conconn.ConcTask.add_callback(t_id)
    Conconn.Client.begin_task(c_id, t_id)
  end
end
