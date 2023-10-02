defmodule Conconn.Utils do
  def log_measure(function, label \\ "No label") do
    {time, result} = :timer.tc(function)
    IO.inspect(%{
      label: label,
      time: time
    })
    result
  end
end
