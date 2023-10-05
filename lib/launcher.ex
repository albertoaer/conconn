defmodule Conconn.Launcher do
  alias Conconn.{ClientSupervisor, ConcTaskSupervisor}

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
    count = for {:begin_task, pid} <- perform_launch(opts) do
      Conconn.ConcTask.add_callback(pid)
    end |> length
    loop(count, 0)
  end

  def loop(count, received) when received >= count, do: :ok

  def loop(count, received) do
    receive do
      :completed -> loop(count, received + 1)
      _ -> loop(count, received)
    end
  end

  defp perform_launch(items) when is_list(items), do: Enum.map(items, fn item -> apply(&launch/3, Tuple.to_list(item)) end)

  defp perform_launch({client, task, count}) do
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
