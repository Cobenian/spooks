defmodule Spooks.Sample.SampleWorkflow do
  use Spooks.Workflow

  alias Spooks.Sample.{StepOneEvent, StepTwoEvent, HumanInputEvent, StepThreeEvent, StepFourEvent}

  @step %Step{in: StartEvent, out: StepOneEvent}
  def start_step(%SpooksContext{} = ctx, %StartEvent{} = start_event) do
    IO.puts("Hello, world! #{inspect(start_event)}")
    {:ok, ctx, %StepOneEvent{}}
  end

  @step %Step{in: StepOneEvent, out: StepTwoEvent}
  def step_one_step(%SpooksContext{} = ctx, %StepOneEvent{} = step_one_event) do
    IO.puts("Step one! #{inspect(step_one_event)}")
    {:ok, ctx, %StepTwoEvent{}}
  end

  @step %Step{in: StepTwoEvent, out: HumanInputEvent}
  def step_two_step(%SpooksContext{} = ctx, %StepTwoEvent{} = step_two_event) do
    IO.puts("Step two! #{inspect(step_two_event)}")
    {:ok, ctx, %HumanInputEvent{}}
  end

  @step %Step{in: HumanInputEvent, out: StepThreeEvent}
  def human_input_step(%SpooksContext{} = ctx, %HumanInputEvent{} = human_input_event) do
    IO.puts("Human input! #{inspect(human_input_event)}")
    {:ok, ctx, %StepThreeEvent{}}
  end

  @step %Step{in: StepThreeEvent, out: [StepFourEvent, EndEvent]}
  def step_three_step(%SpooksContext{} = ctx, %StepThreeEvent{} = step_three_event) do
    IO.puts("Step three! #{inspect(step_three_event)}")
    {:ok, ctx, %EndEvent{}}
  end

  @step %Step{in: StepFourEvent, out: EndEvent}
  def step_four_step(%SpooksContext{} = ctx, %StepFourEvent{} = step_four_event) do
    IO.puts("Step four! #{inspect(step_four_event)}")
    {:ok, ctx, %EndEvent{}}
  end

  @step %Step{in: EndEvent, out: nil}
  def end_step(%SpooksContext{} = ctx, %EndEvent{} = end_event) do
    IO.puts("Goodbye, world! #{inspect(end_event)}")
    {:ok, ctx, nil}
  end
end
