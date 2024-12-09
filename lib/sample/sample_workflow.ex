defmodule Spooks.Sample.SampleWorkflow do
  use Spooks.Workflow

  alias Spooks.Sample.{StepOneEvent, StepTwoEvent, HumanInputEvent, StepThreeEvent, StepFourEvent}

  require Logger

  @step %Step{in: StartEvent, out: StepOneEvent}
  def start_step(%StartEvent{} = start_event, %SpooksContext{} = ctx) do
    Logger.info("Hello, world! #{inspect(start_event)}")
    {:ok, ctx, %StepOneEvent{}}
  end

  @step %Step{in: StepOneEvent, out: StepTwoEvent}
  def step_one_step(%StepOneEvent{} = step_one_event, %SpooksContext{} = ctx) do
    Logger.info("Step one! #{inspect(step_one_event)}")
    {:ok, ctx, %StepTwoEvent{}}
  end

  @step %Step{in: StepTwoEvent, out: HumanInputEvent}
  def step_two_step(%StepTwoEvent{} = step_two_event, %SpooksContext{} = ctx) do
    Logger.info("Step two! #{inspect(step_two_event)}")
    {:ok, ctx, %HumanInputEvent{}}
  end

  @step %Step{in: HumanInputEvent, out: StepThreeEvent}
  def human_input_step(%HumanInputEvent{} = human_input_event, %SpooksContext{} = ctx) do
    Logger.info("Human input! #{inspect(human_input_event)}")
    {:ok, ctx, %StepThreeEvent{}}
  end

  @step %Step{in: StepThreeEvent, out: [StepFourEvent, EndEvent], ai: true}
  def step_three_step(%StepThreeEvent{} = step_three_event, %SpooksContext{} = ctx) do
    Logger.info("Step three! #{inspect(step_three_event)}")
    {:ok, ctx, %EndEvent{}}
  end

  @step %Step{in: StepFourEvent, out: EndEvent}
  def step_four_step(%StepFourEvent{} = step_four_event, %SpooksContext{} = ctx) do
    Logger.info("Step four! #{inspect(step_four_event)}")
    {:ok, ctx, %EndEvent{}}
  end

  @step %Step{in: EndEvent, out: nil}
  def end_step(%EndEvent{} = end_event, %SpooksContext{} = ctx) do
    Logger.info("Goodbye, world! #{inspect(end_event)}")
    {:ok, ctx, nil}
  end
end
