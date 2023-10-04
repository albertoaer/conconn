defmodule Conconn.ConcTask.PingPongConcTask do
  use GenServer

  defmodule State do
    @enforce_keys [:traffic, :watch]
    defstruct [:traffic, :watch, :msg, :group]
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %State{
      traffic: Keyword.get(opts, :traffic, 1),
      watch: Conconn.StopWatch.new,
      group: Keyword.get(opts, :group, :unknown)
    })
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:next, msg}, _from, state) do
    cond do
      msg == state.msg ->
        state = next(state)
        if state.msg do
          {:reply, {:ok, state.msg}, state}
        else
          {:stop, :normal, {:ok}, state}
        end
      state.msg ->
        {:reply, {:continue}, state}
      true ->
        {:reply, {:ok}, state}
    end
  end

  @impl true
  def terminate(_reason, %State{watch: watch, group: group}), do: Conconn.ResultCollector.put(watch, group)

  defp next(%State{traffic: 0, watch: watch} = state), do: %{
    state | msg: nil, watch: Conconn.StopWatch.stop(watch)
  }

  defp next(%State{traffic: traffic, watch: watch} = state), do: %{
    state | traffic: traffic-1, msg: uuid(), watch: Conconn.StopWatch.stop_start(watch)
  }

  def uuid, do: :crypto.strong_rand_bytes(16) |> Base.encode16()
end
