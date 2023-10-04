defmodule Conconn.Client do
  defmacro __using__(_opts) do
    quote do
      def launch(arg, producer, count \\ 1), do: Conconn.Launcher.launch({__MODULE__, arg}, producer, count)
    end
  end
end
