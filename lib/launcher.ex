defmodule Conconn.Launcher do
  alias Conconn.{ClientSupervisor, ConcTaskSupervisor}

  def launch(items) when is_list(items), do: Enum.map(items, fn item -> apply(&launch/3, Tuple.to_list(item)) end)

  def launch(client, task, count \\ 1) do
    for _ <- 0..count-1 do
      start_test_client_pair(client, task)
    end
  end

  defp start_test_client_pair(client, task) do
    {:ok, c_id} = produce_child_config(client) |> ClientSupervisor.start_child()
    {:ok, t_id} = produce_child_config(task) |> ConcTaskSupervisor.start_child()
    send(c_id, {:begin_task, t_id})
  end

  defp produce_child_config(spec) do
    Supervisor.child_spec(spec, restart: :transient)
  end
end
