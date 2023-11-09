defmodule Conconn.ConcTask do
  defmodule State do
    @enforce_keys [:group, :callbacks, :task_state, :watch]
    defstruct [:group, :callbacks, :task_state, :watch]
  end

  @callback init(opts :: term) :: {:ok, state :: term} | {:error, reason :: term}

  @callback handle_next(msg :: term, state :: term) ::
    {:ok, msg :: term, state :: term} | {:continue, state :: term} | {:stop, state :: term}

  defmacro __using__(_opts) do
    quote do
      @behaviour Conconn.ConcTask

      @abort_time 3_000

      use Task, restart: :transient

      def loop(state) do
        receive do
          {:next, msg, pid} -> recv_next(state, msg, pid)
          {:callback, pid} -> recv_callback(state, pid)
        after @abort_time
          -> terminate(state, false)
        end
      end

      defp recv_next(%State{task_state: task_state, watch: watch} = state, msg, pid) do
        {response, stop, task_state, watch} = case handle_next(msg, task_state) do
          {:ok, msg, state} -> {{:ok, msg}, false, state, Conconn.StopWatch.stop_start(watch)}
          {:continue, state} -> {:continue, false, state, watch}
          {:stop, state} -> {:ok, true, state, Conconn.StopWatch.stop(watch)}
        end
        send(pid, {:conctask, response})
        state = %{state | task_state: task_state, watch: watch}
        if stop, do: terminate(state), else: loop(state)
      end

      defp terminate(%State{callbacks: callbacks, watch: watch, group: group}, ok \\ true) do
        msg = if ok, do: {:completed, watch}, else: :failure
        Enum.map(callbacks, fn callback -> send(callback, msg) end)
      end

      defp recv_callback(%State{callbacks: callbacks}=state, pid) do
        loop(%{state | callbacks: [pid | callbacks]})
      end
    end
  end

  def start_link(module, opts) do
    Task.start_link(fn ->
      case apply(module, :init, [opts]) do
        {:ok, state} -> module.loop(%State{
          group: :unknown,
          callbacks: [],
          task_state: state,
          watch: Conconn.StopWatch.new()
        })
        {:error, reason} -> throw reason
      end
    end)
  end

  def next(task, msg \\ nil) do
    send(task, {:next, msg, self()})
    receive do
      {:conctask, msg} -> msg
    end
  end

  def add_callback(task), do: send(task, {:callback, self()})
end
