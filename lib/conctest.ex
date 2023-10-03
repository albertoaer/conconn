defmodule Conconn.ConcTest do
  def get(pid), do: GenServer.call(pid, {:get})

  def verify(pid, msg), do: GenServer.call(pid, {:verify, msg})
end
