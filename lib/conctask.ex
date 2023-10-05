defmodule Conconn.ConcTask do
  def next(pid, msg \\ nil), do: GenServer.call(pid, {:next, msg})

  def add_callback(pid), do: GenServer.cast(pid, {:callback, self()})
end
