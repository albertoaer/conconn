defmodule Conconn.ConcTask.EmitConcTask do
  use Conconn.ConcTask

  defmodule State do
    @enforce_keys [:traffic]
    defstruct [:traffic, :msg]
  end

  def start_link(opts) do
    Conconn.ConcTask.start_link(__MODULE__, %State{
      traffic: Keyword.get(opts, :traffic, 1),
    })
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_next(_, state) do
    state = next(state)
    if state.msg do
      {:ok, state.msg, state}
    else
      {:stop, state}
    end
  end

  defp next(%State{traffic: 0} = state), do: %{state | msg: nil}

  defp next(%State{traffic: traffic} = state), do: %{state | traffic: traffic-1, msg: uuid()}

  def uuid, do: :crypto.strong_rand_bytes(16) |> Base.encode16()
end
