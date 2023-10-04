defmodule Conconn.ConcTaskSupervisor do
  use DynamicSupervisor

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 20, max_seconds: 10)
  end

  def start_child(child) do
    DynamicSupervisor.start_child(__MODULE__, child)
  end
end
