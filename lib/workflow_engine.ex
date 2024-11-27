defmodule Spooks.WorkflowEngine do
  alias Spooks.Context.SpooksContext
  alias Spooks.Event.StartEvent

  def main() do
    run_workflow(Spooks.Sample.SampleWorkflow)
  end

  def run_workflow(workflow_module) do
    _workflow_context = %SpooksContext{}
    _start_event = %StartEvent{}

    _steps =
      workflow_module.steps()
      |> IO.inspect(label: "steps")
  end
end
