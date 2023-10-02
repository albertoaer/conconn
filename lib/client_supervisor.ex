defmodule Conconn.ClientSupervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init(args) when is_tuple(args) do
    init([args])
  end

  def init(args) when is_list(args) do
    clients = Enum.reduce(args, [], fn item, acc -> acc ++ generate_clients(item, length(acc)) end)
    Supervisor.init(clients, strategy: :one_for_one, max_restarts: 20, max_seconds: 10)
  end

  defp generate_clients({client, client_args, count}, sub_idx) when is_list(client_args) do
    for idx <- 1..count do
      Supervisor.child_spec({client, Keyword.put(client_args, :id, :"client_#{idx}_#{sub_idx}")}, id: {:client, idx, sub_idx})
    end
  end
end
