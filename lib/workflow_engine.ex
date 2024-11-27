defmodule Spooks.WorkflowEngine do
  @moduledoc """
  The Spooks Workflow Engine is responsible for running agentic workflows.

  A workflow context is also provided that contains information about how the workflow engine should run.
  The context holds the workflow module, the repository (if using checkpoints), and an optional llm that can be used by the workflow agent steps.

  There is an event that is passed to each step in the workflow. This event name is used to determine the step function that is called. 
  The function returns a new event which determines the next step in the workflow.

  ## Example

      ctx = Spooks.Context.SpooksContext.new(Spooks.Sample.SampleWorkflow, nil)
      Spooks.WorkflowEngine.run_workflow(ctx)
  """

  alias Spooks.Context.SpooksContext
  alias Spooks.Event.StartEvent

  alias Spooks.Checkpoint.SpookCheckpoints

  require Logger

  @doc false
  def sample(repo \\ nil) do
    run_workflow(
      SpooksContext.new(
        Spooks.Sample.SampleWorkflow,
        repo
      )
    )
  end

  @doc """
  Runs the agentic workflow for the given context.

  IF there is a repo, it will check for a checkpoint and resume the workflow.
  """
  def run_workflow(workflow_context) do
    Logger.info(
      "running workflow: #{workflow_context.workflow_module} with identifier: #{workflow_context.workflow_identifier}"
    )

    if SpookCheckpoints.has_checkpoint?(workflow_context) do
      resume_workflow(workflow_context)
    else
      start_workflow(workflow_context)
    end
  end

  @doc """
  Starts a workflow for the given context. Ignores any existing checkpoints.
  """
  def start_workflow(workflow_context) do
    start_event = %StartEvent{}

    run_step(workflow_context, start_event)
  end

  @doc """
  Resumes a workflow for the given context. Uses the last checkpoint to determine the next step.

  If there is no checkpoint, it will raise an error.
  """
  def resume_workflow(workflow_context) do
    checkpoint =
      case workflow_context.repo do
        nil ->
          raise "Cannot resume workflow without a repo"

        _repo ->
          SpookCheckpoints.get_checkpoint(workflow_context)
      end

    event = SpookCheckpoints.get_checkpoint_event(checkpoint)
    workflow_context = SpookCheckpoints.get_workflow_context(checkpoint)
    run_step(workflow_context, event)
  end

  @doc """
  Runs a step in the workflow for the given context.

  If the step returns an event, it will save a checkpoint and run the next step.
  If the step returns nil, it will remove the checkpoint and end the workflow.

  If the step function does not exist in the workflow module, it will raise an error.
  """
  def run_step(workflow_context, event) do
    step_name = get_step_function_name(event)
    Logger.debug("Running step: #{step_name}")

    workflow_module = workflow_context.workflow_module
    Logger.info("Running step: #{workflow_module}.#{step_name}/2")

    function =
      workflow_context.workflow_module.__info__(:functions)
      |> Enum.filter(fn
        {func_name, 2 = _arity} -> func_name == step_name
        _ -> false
      end)

    if function != nil do
      apply(workflow_module, step_name, [event, workflow_context])
      |> case do
        {:ok, ctx, nil} ->
          SpookCheckpoints.remove_checkpoint(ctx)
          Logger.info("Workflow complete!")
          ctx

        {:ok, ctx, event} ->
          SpookCheckpoints.save_checkpoint(ctx, event)
          run_step(ctx, event)
      end
    else
      raise "No function found for step: #{workflow_module}.#{step_name}/2"
    end
  end

  defp get_event_name(event) do
    event.__struct__
    |> Atom.to_string()
    |> String.split(".")
    |> List.last()
    |> Macro.underscore()
    |> String.trim("_event")
  end

  defp get_step_name(event_name) do
    "#{event_name}_step" |> String.to_atom()
  end

  @doc """
  Gets the name of the step function for the given event.
  """
  def get_step_function_name(event) do
    event
    |> get_event_name()
    |> get_step_name()
  end
end
