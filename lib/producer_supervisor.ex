defmodule Conconn.ProducerSupervisor do
  use DynamicSupervisor

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def get_or_start_link(name, init) do
    if pid = Process.whereis(name) do
      pid
    else
      {:ok, pid} = DynamicSupervisor.start_child(__MODULE__, Supervisor.child_spec(init, restart: :transient))
      Process.register(pid, name)
      pid
    end
  end
end
