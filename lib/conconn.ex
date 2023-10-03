defmodule Conconn do
  alias Conconn.{
    ConcTest.PingPongConcTest,
    Client.WebSocket,
    ConcTestSupervisor,
    ResultCollector
  }
  use Application

  def start(_type, _args) do
    childs = [
      ResultCollector,
      ConcTestSupervisor,
      {
        Conconn.ClientSupervisor,
        [
          {
            WebSocket,
            [
              url: "ws://localhost:8080/ws/xd",
              producer: {
                PingPongConcTest, traffic: 100, group: 1
              }
            ],
            20
          },
          {
            WebSocket,
            [
              url: "ws://localhost:8080/ws/xd2",
              producer: {
                PingPongConcTest, traffic: 100, group: 2
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
