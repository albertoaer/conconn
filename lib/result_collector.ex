defmodule Conconn.ResultCollector do
  use GenServer

  alias Conconn.StopWatch

  defmodule Sample do
    defstruct count: 0, avg_time: 0, total_time_s: 0
  end

  defmodule GroupResults do
    defstruct stored: [], samples: 0, count: 0, avg_time: 0, total_time_s: 0

    def append(nil, sample), do: append(%GroupResults{}, sample)
    def append(%GroupResults{} = results, %Sample{} = sample) do
      n_count = results.count + sample.count
      %{results |
        stored: if(Process.get(:store_samples, false), do: [sample | results.stored], else: []),
        samples: results.samples + 1,
        count: n_count,
        avg_time: ((results.avg_time * results.count) + (sample.avg_time * sample.count)) / n_count,
        total_time_s: results.total_time_s + sample.total_time_s
      }
    end

    def summary(%GroupResults{} = results), do: Map.from_struct(results) |> Map.delete(:stored)
  end

  defmodule Results do
    defstruct groups: %{}

    def new, do: %Results{}

    def include(%Results{groups: groups}, group, sample) do
      {_, groups} = Map.get_and_update(groups, group, fn
        value -> {value, GroupResults.append(value, sample)}
      end)
      %Results{groups: groups}
    end

    def get(%Results{groups: groups}, group) do
      Map.get(groups, group)
    end

    def summary(%Results{groups: groups}) do
      Map.to_list(groups) |> Enum.map(fn {key, value} -> {key, GroupResults.summary(value)} end) |> Map.new
    end
  end

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(arg) do
    Process.put(:log, Keyword.get(arg, :log, false))
    Process.put(:store_samples, Keyword.get(arg, :store_samples, false))
    {:ok, Results.new}
  end

  @impl true
  def handle_cast({:put, %StopWatch{} = metrics, group}, state) do
    sample = %Sample{
      count: StopWatch.count(metrics),
      avg_time: StopWatch.avg(metrics),
      total_time_s: StopWatch.sum(metrics)/1000,
    }
    if Process.get(:log, false), do: sample |> IO.inspect(label: "Got Results", width: 70)
    {:noreply, Results.include(state, group, sample)}
  end

  @impl true
  def handle_call(:summary, _from, state) do
    {:reply, state |> Results.summary, state}
  end

  @impl true
  def handle_call({:summary, group}, _from, state) do
    {:reply, state |> Results.get(group) |> GroupResults.summary, state}
  end

  def put(metrics, group \\ :unknown), do: GenServer.cast(__MODULE__, {:put, metrics, group})

  def summary(group \\ nil) do
    GenServer.call(__MODULE__, if(group, do: {:summary, group}, else: :summary))
  end
end
