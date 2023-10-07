defmodule Conconn.Launcher.Supervisor do
  use DynamicSupervisor

  def start_link(opts \\ nil) do
    DynamicSupervisor.start_link(__MODULE__, opts)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 20, max_seconds: 10)
  end

  def start_child(pid, child) do
    DynamicSupervisor.start_child(pid, Supervisor.child_spec(child, restart: :transient))
  end
end
