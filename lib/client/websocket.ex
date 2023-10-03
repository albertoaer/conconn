defmodule Conconn.Client.WebSocket do
  use WebSockex

  defmodule Data do
    @enforce_keys [:id, :producer]
    defstruct [:id, :producer]
  end

  def start_link(opts) do
    WebSockex.start_link(Keyword.get(opts, :url), __MODULE__, %Data{
      id: Keyword.get(opts, :id),
      producer: Keyword.get(opts, :producer)
    })
  end

  @impl true
  def handle_connect(conn, state) do
    target = self()
    response = Conconn.ConcTest.get(producer(state))
    spawn(fn
      -> case response do
        {:ok, msg} -> WebSockex.send_frame(target, {:text, msg})
        _ -> WebSockex.Conn.close_socket(conn)
      end
    end)
    {:ok, state}
  end

  @impl true
  def handle_frame({:text, response}, state) do
    case Conconn.ConcTest.verify(producer(state), response) do
      {:ok, msg} -> {:reply, {:text, msg}, state}
      {:ok} -> {:close, state}
      _ -> {:ok, state}
    end
  end

  @impl true
  def handle_disconnect(_connection_status_map, state) do
    IO.puts("Disconnected")
    {:ok, state}
  end

  defp producer(%Data{ id: id, producer: producer }) do
    Conconn.ConcTestSupervisor.get_or_start_link(id, producer)
  end
end
