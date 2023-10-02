defmodule Conconn.ProducerSupervisor do
  use DynamicSupervisor

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def get_or_start_link(name, init) do
    if pid = Process.whereis(name) do
      pid
    else
      {:ok, pid} = DynamicSupervisor.start_child(__MODULE__, init)
      Process.register(pid, name)
      pid
    end
  end
end
