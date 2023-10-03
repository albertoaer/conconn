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
        [
          {
            WebSocket,
            [
              url: "ws://localhost:8080/ws/xd",
              producer: {
                PingPongProducer, traffic: 100, group: 1
              }
            ],
            20
          },
          {
            WebSocket,
            [
              url: "ws://localhost:8080/ws/xd2",
              producer: {
                PingPongProducer, traffic: 100, group: 2
              }
            ],
            20
          }
        ]
      }
    ]
    Supervisor.start_link(childs, strategy: :one_for_one)
  end
end
