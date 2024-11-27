# defmodule Spooks.Sample.SampleWorkflow do
#   use Spooks.Workflow

#   alias Spooks.Sample.{StepOneEvent, StepTwoEvent, HumanInputEvent, StepThreeEvent, StepFourEvent}

#   @step %Step{outputs: [StepOneEvent]}
#   def start_workflow(%StartEvent{} = _start_event, %SpooksContext{} = _ctx) do
#     IO.puts "Hello, world!"
#     {:ok, %StepOneEvent{}}
#   end

#   @step %Step{outputs: [StepTwoEvent]}
#   def step_one(%StepOneEvent{} = _step_one_event, %SpooksContext{} = _ctx) do
#     IO.puts "Step one!"
#     {:ok, %StepTwoEvent{}}
#   end

#   @step %Step{outputs: [HumanInputEvent]}
#   def step_two(%StepTwoEvent{} = _step_two_event, %SpooksContext{} = _ctx) do
#     IO.puts "Step two!"
#     {:ok, %HumanInputEvent{}}
#   end

#   @step %Step{outputs: [StepThreeEvent]}
#   def human_input(%HumanInputEvent{} = _human_input_event, %SpooksContext{} = _ctx) do
#     IO.puts "Human input!"
#     {:ok, %StepThreeEvent{}}
#   end

#   @step %Step{outputs: [StepFourEvent, EndEvent]}
#   def step_three(%StepThreeEvent{} = _step_three_event, %SpooksContext{} = _ctx) do
#     IO.puts "Step three!"
#     {:ok, %EndEvent{}}
#   end

#   @step %Step{outputs: [EndEvent]}
#   def step_four(%StepFourEvent{} = _step_four_event, %SpooksContext{} = _ctx) do
#     IO.puts "Step four!"
#     {:ok, %EndEvent{}}
#   end

#   @step %Step{outputs: []}
#   def end_workflow(%EndEvent{} = _end_event, %SpooksContext{} = _ctx) do
#     IO.puts "Goodbye, world!"
#     {:ok, nil}
#   end

# end
