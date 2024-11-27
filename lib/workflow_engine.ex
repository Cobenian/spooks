defmodule Spooks.WorkflowEngine do
  alias Spooks.Context.SpooksContext
  alias Spooks.Event.StartEvent
  alias Spooks.Schema.WorkflowCheckpoint

  require Logger

  def main(repo \\ nil) do
    run_workflow(
      SpooksContext.new(
        Spooks.Sample.SampleWorkflow,
        repo
      )
    )
  end

  def run_workflow(workflow_context) do
    Logger.info(
      "running workflow: #{workflow_context.workflow_module} with identifier: #{workflow_context.workflow_identifier}"
    )

    if has_checkpoint?(workflow_context) do
      resume_workflow(workflow_context)
    else
      start_workflow(workflow_context)
    end
  end

  def start_workflow(workflow_context) do
    start_event = %StartEvent{}

    run_step(workflow_context, start_event)
  end

  def resume_workflow(workflow_context) do
    checkpoint =
      case workflow_context.repo do
        nil ->
          raise "Cannot resume workflow without a repo"

        repo ->
          repo.get_by(WorkflowCheckpoint,
            workflow_identifier: workflow_context.workflow_identifier
          )
      end

    run_step(checkpoint.workflow_context, checkpoint.workflow_event)
  end

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
      apply(workflow_module, step_name, [workflow_context, event])
      |> case do
        {:ok, ctx, nil} ->
          remove_checkpoint(ctx)
          IO.puts("Workflow complete!")
          ctx

        {:ok, ctx, event} ->
          save_checkpoint(ctx, event)
          run_step(ctx, event)
      end
    else
      raise "No function found for step: #{workflow_module}.#{step_name}/2"
    end
  end

  def get_checkpoint(workflow_context) do
    case workflow_context.repo do
      nil ->
        nil

      repo ->
        repo.get_by(WorkflowCheckpoint, workflow_identifier: workflow_context.workflow_identifier)
    end
  end

  def has_checkpoint?(workflow_context) do
    get_checkpoint(workflow_context) != nil
  end

  def remove_checkpoint(workflow_context) do
    workflow_context
    |> get_checkpoint()
    |> case do
      nil ->
        {:ok, nil}

      checkpoint ->
        case workflow_context.repo do
          nil ->
            {:ok, nil}

          repo ->
            repo.delete(checkpoint)
        end
    end
  end

  def save_checkpoint(workflow_context, event) do
    case workflow_context.repo do
      nil ->
        {:ok, nil}

      repo ->
        workflow_context
        |> get_checkpoint()
        |> case do
          nil ->
            %WorkflowCheckpoint{}
            |> WorkflowCheckpoint.create_changeset(%{
              "workflow_identifier" => workflow_context.workflow_identifier,
              "workflow_module" => Atom.to_string(workflow_context.workflow_module),
              "workflow_context" => workflow_context,
              "workflow_event" => event
            })
            |> repo.insert()

          checkpoint ->
            checkpoint
            |> WorkflowCheckpoint.update_changeset(%{
              "workflow_context" => workflow_context,
              "workflow_event" => event
            })
            |> repo.update()
        end
    end
  end

  def get_event_name(event) do
    event.__struct__
    |> Atom.to_string()
    |> String.split(".")
    |> List.last()
    |> Macro.underscore()
    |> String.trim("_event")
  end

  def get_step_name(event_name) do
    "#{event_name}_step" |> String.to_atom()
  end

  def get_step_function_name(event) do
    event
    |> get_event_name()
    |> get_step_name()
  end
end
