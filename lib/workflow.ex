defmodule Spooks.Workflow do
  defmacro __using__(_) do
    quote do
      Module.register_attribute(__MODULE__, :step, accumulate: true, persist: true)
      # Module.register_attribute(__MODULE__, :steps, accumulate: false, persist: true)

      alias Spooks.Event.StartEvent
      alias Spooks.Event.EndEvent
      alias Spooks.Context.SpooksContext
      alias Spooks.Context.Step

      @steps []

      def steps() do
        @steps
      end

      @before_compile Spooks.Workflow
    end
  end

  def __before_compile__(env) do
    IO.puts("before compile env #{env.module}")
    steps = Module.get_attribute(env.module, :step)
    IO.puts("steps: #{inspect(Enum.count(steps))}")
    functions = Module.definitions_in(env.module, :def)
    IO.puts("functions: #{inspect(Enum.count(functions))}")

    step_functions = for {func, _arity} <- functions, step <- steps, do: {func, step}

    Enum.map(step_functions, fn {func, step} ->
      IO.puts("func: #{inspect(func)} step: #{inspect(step)}")
    end)

    IO.puts("step_functions: #{inspect(Enum.count(step_functions))}")
    Module.put_attribute(env.module, :steps, step_functions)
  end
end
