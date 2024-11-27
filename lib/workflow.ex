defmodule Spooks.Workflow do
  defmacro __using__(_) do
    quote do
      Module.register_attribute(__MODULE__, :step, accumulate: true, persist: true)

      alias Spooks.Event.StartEvent
      alias Spooks.Event.EndEvent
      alias Spooks.Context.SpooksContext
      alias Spooks.Context.Step

      def steps() do
        __MODULE__.__info__(:attributes)
        |> Keyword.get_values(:step)
        |> List.flatten()
      end
    end
  end
end
