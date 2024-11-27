defmodule Spooks.Workflow do
  @doc """
  Add `use Spooks.Workflow` to your workflow module to enable the `@step` attribute.

  ## Example

      defmodule MyWorkflow do
        use Spooks.Workflow

        @step %Step{in: StartEvent, out: StepOneEvent}
        def start_step(%StartEvent{} = start_event, %SpooksContext{} = ctx) do
          {:ok, ctx, %StepOneEvent{}}
        end
      end
  """
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
