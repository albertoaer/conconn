defmodule Conconn.Producer do
  def get(pid), do: GenServer.call(pid, {:get})

  def verify(pid, msg), do: GenServer.call(pid, {:verify, msg})
end
