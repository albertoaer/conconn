defmodule Conconn do
  alias Conconn.{
    ResultCollector,
    ConcTaskSupervisor,
    ClientSupervisor,
  }
  use Application

  def start(_type, _args) do
    childs = [
      ResultCollector,
      ConcTaskSupervisor,
      ClientSupervisor,
    ]
    Supervisor.start_link(childs, strategy: :one_for_one)
  end
end
