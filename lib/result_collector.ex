defmodule Conconn.ResultCollector do
  use GenServer

  alias Conconn.StopWatch

  defmodule Results do
    defstruct stored: []

    def append(%Results{stored: stored}, data) when is_list(data), do: %Results{stored: data ++ stored}
    def append(%Results{stored: stored}, data), do: %Results{stored: [data | stored]}
  end

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, %Results{}, name: __MODULE__)
  end

  @impl true
  def init(arg) do
    {:ok, arg}
  end

  @impl true
  def handle_cast({:put, %StopWatch{} = metrics}, state) do
    count = StopWatch.count(metrics)
    avg = StopWatch.avg(metrics)
    total = StopWatch.sum(metrics)/1000
    IO.puts("Got a sample of #{count} elements with an average of #{avg} ms and a total time of #{total} s")
    {:noreply, Results.append(state, {count, avg})}
  end

  def put(metrics), do: GenServer.cast(__MODULE__, {:put, metrics})
end
