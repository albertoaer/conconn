defmodule Conconn.ConcTask do
  def next(pid, msg \\ nil), do: GenServer.call(pid, {:next, msg})
end
