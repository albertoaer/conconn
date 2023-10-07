defmodule Conconn.Launcher do
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
    {:ok, supervisor} = Conconn.Launcher.Supervisor.start_link()
    {:ok, results} = Conconn.Launcher.Supervisor.start_child(supervisor, Conconn.ResultCollector)
    launch_groups(opts, supervisor, results) |> Task.await_many(:infinity)
    Conconn.ResultCollector.summary(results)
  end

  defp launch_groups(items, supervisor, results) when is_list(items), do: items |> Enum.with_index(1) |> Enum.map(
    fn
      {item, idx} -> launch_group(item, supervisor, results, idx)
    end
  )

  defp launch_groups(items, supervisor, results) when is_tuple(items) do
    [launch_group(items, supervisor, results, 1)]
  end

  defp launch_group(item, supervisor, results, group) do
    Task.async(Conconn.Launcher.Group, :launch_group, [item, supervisor, results, group])
  end
end
