defmodule Conconn do
  alias Conconn.{
    Producer.PingPongProducer,
    Client.WebSocket,
    ProducerSupervisor,
    ResultCollector
  }
  use Application

  def start(_type, _args) do
    childs = [
      ResultCollector,
      ProducerSupervisor,
      {
        Conconn.ClientSupervisor,
        {
          WebSocket,
          [
            url: "ws://localhost:8080/ws/xd",
            producer: {
              PingPongProducer, [traffic: 100]
            }
          ],
          500
        }
      }
    ]
    Supervisor.start_link(childs, strategy: :one_for_one)
  end
end
