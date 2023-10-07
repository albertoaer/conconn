defmodule Conconn.Client.WebSocket do
  use Conconn.Client
  use WebSockex

  defmodule State do
    defstruct [:task_id, :conn]
  end

  def start_link(url) do
    WebSockex.start_link(url, __MODULE__, %State{})
  end

  @impl true
  def handle_connect(conn, state), do: try_begin(%{state | conn: conn})

  @impl true
  def handle_frame({:text, response}, %State{task_id: task_id} = state) when is_pid(task_id) do
    case Conconn.ConcTask.next(task_id, response) do
      {:ok, msg} -> {:reply, {:text, msg}, state}
      :ok -> {:close, state}
      :continue -> {:ok, state}
    end
  end

  @impl true
  def handle_frame(_frame, state), do: {:ok, state}

  @impl true
  def handle_disconnect(_connection_status_map, state) do
    {:ok, state}
  end

  @impl true
  def handle_info({:begin_task, id}, state), do: try_begin(%{state | task_id: id})

  @impl true
  def handle_info(_msg, state), do: {:ok, state}

  def try_begin(%State{task_id: task_id, conn: conn} = state) do
    if !!task_id and !!conn do
      target = self()
      response = Conconn.ConcTask.next(task_id)
      Task.start_link(fn
        -> case response do
          {:ok, msg} -> WebSockex.send_frame(target, {:text, msg})
          _ -> WebSockex.Conn.close_socket(conn)
        end
      end)
    end
    {:ok, state}
  end
end
