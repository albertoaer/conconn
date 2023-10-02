defmodule Conconn.ClientSupervisor do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  def init(arg) when is_tuple(arg) do
    init([arg])
  end

  def init(arg) when is_list(arg) do
    clients = Enum.reduce(arg, [], fn item, acc -> acc ++ generate_clients(item, length(acc)) end)
    Supervisor.init(clients, strategy: :one_for_one, max_restarts: 20, max_seconds: 10)
  end

  defp generate_clients({client, client_args, count}, sub_idx) when is_list(client_args) do
    for idx <- 1..count do
      Supervisor.child_spec(
        {
          client,
          Keyword.put(client_args, :id, :"client_#{idx}_#{sub_idx}")
        },
        id: {:client, idx, sub_idx},
        restart: :transient
      )
    end
  end
end
