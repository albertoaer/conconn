defmodule Conconn.StopWatch do
  defstruct laps: [], init: nil

  def new, do: %__MODULE__{}

  def new_start, do: %__MODULE__{init: time()}


  def start(%__MODULE__{init: init} = watch) when is_nil(init), do: %{watch | init: time()}

  def start(watch), do: watch


  def stop(%__MODULE__{init: init} = watch) when is_nil(init), do: watch

  def stop(%__MODULE__{laps: laps, init: init}), do: %__MODULE__{laps: [time() - init | laps], init: nil}


  def stop_start(%__MODULE__{init: init} = watch) when is_nil(init), do: start(watch)

  def stop_start(%__MODULE__{laps: laps, init: init}) do
    time = time()
    %__MODULE__{laps: [time - init | laps], init: time}
  end


  def count(%__MODULE__{laps: laps}), do: length(laps)

  def sum(%__MODULE__{laps: laps}), do: Enum.sum(laps)

  def avg(%__MODULE__{laps: laps} = watch), do: sum(watch) / length(laps)


  def time, do: :os.system_time(:milli_seconds)
end
