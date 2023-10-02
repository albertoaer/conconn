defmodule Conconn.Producer.PingPongProducer do
  use GenServer

  defmodule State do
    @enforce_keys [:traffic]
    defstruct [:traffic, :msg]
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %State{traffic: Keyword.get(opts, :traffic)})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:get}, _from, state) do
    state = next(state)
    if state.msg do
      {:reply, {:ok, state.msg}, state}
    else
      {:reply, {:ok}, state}
    end
  end

  def handle_call({:verify, msg}, _from, state) do
    cond do
      msg == state.msg ->
        state = next(state)
        if state.msg do
          {:reply, {:ok, state.msg}, state}
        else
          {:reply, {:ok}, state}
        end
      state.msg ->
        {:reply, {:continue}, state}
      true ->
        {:reply, {:ok}, state}
    end
  end

  defp next(%State{traffic: 0} = state), do: %{state | msg: nil}

  defp next(%State{traffic: traffic} = state), do: %{state | traffic: traffic-1, msg: uuid()}

  def uuid, do: :crypto.strong_rand_bytes(16) |> Base.encode16()
end
