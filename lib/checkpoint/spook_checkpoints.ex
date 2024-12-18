defmodule Spooks.Checkpoint.SpookCheckpoints do
  alias Spooks.Schema.WorkflowCheckpoint
  alias Spooks.Context.SpooksContext

  @moduledoc """
  Logic for handling checkpoints (saving and retrieving the state of agent workflows) in Spooks.

  Right now Ecto is the only supported repository for checkpoints.
  """

  @doc """
  Checks if checkpoints are enabled for the given context.
  """
  def checkpoints_enabled?(%SpooksContext{} = workflow_context) do
    workflow_context.checkpoints_enabled == true
  end

  @doc """
  After retrieving a checkpoint from the database we must convert its data back into a struct.
  """
  def get_checkpoint_event(%WorkflowCheckpoint{} = checkpoint) do
    event_module = checkpoint.workflow_event_module
    event_data = checkpoint.workflow_event
    struct(event_module, event_data)
  end

  @doc """
  After retrieving a checkpoint from the database we must convert its data back into a struct.
  """
  def get_workflow_context(%WorkflowCheckpoint{} = checkpoint) do
    context_module = Spooks.Context.SpooksContext
    context_data = checkpoint.workflow_context
    struct(context_module, context_data)
  end

  @doc """
  Gets the checkpoint for the given context. Returns nil if there is no checkpoint.
  """
  def get_checkpoint(%SpooksContext{} = workflow_context) do
    case workflow_context.repo do
      nil ->
        nil

      repo ->
        repo.get_by(WorkflowCheckpoint, workflow_identifier: workflow_context.workflow_identifier)
    end
  end

  @doc """
  Checks if there is a checkpoint for the given context.
  """
  def has_checkpoint?(%SpooksContext{} = workflow_context) do
    get_checkpoint(workflow_context) != nil
  end

  @doc """
  Removes the checkpoint for the given context.
  """
  def remove_checkpoint(%SpooksContext{} = workflow_context) do
    workflow_context
    |> get_checkpoint()
    |> case do
      nil ->
        {:ok, nil}

      %WorkflowCheckpoint{} = checkpoint ->
        case workflow_context.repo do
          nil ->
            {:ok, nil}

          repo ->
            repo.delete(checkpoint)
        end
    end
  end

  @doc """
  Saves a checkpoint for the given context and event.
  """
  def save_checkpoint(%SpooksContext{} = workflow_context, event) do
    case workflow_context.repo do
      nil ->
        {:ok, nil}

      repo ->
        workflow_context
        |> get_checkpoint()
        |> case do
          nil ->
            timeout_in_minutes = workflow_context.checkpoint_timeout_in_minutes || 60 * 48

            %WorkflowCheckpoint{}
            |> WorkflowCheckpoint.create_changeset(%{
              "workflow_identifier" => workflow_context.workflow_identifier,
              "workflow_module" => Atom.to_string(workflow_context.workflow_module),
              "workflow_context" => workflow_context,
              "workflow_event_module" => Atom.to_string(event.__struct__),
              "workflow_event" => event,
              "checkpoint_timeout" =>
                NaiveDateTime.add(NaiveDateTime.utc_now(), timeout_in_minutes, :minute)
            })
            |> repo.insert()

          checkpoint ->
            checkpoint
            |> WorkflowCheckpoint.update_changeset(%{
              "workflow_context" => workflow_context,
              "workflow_event_module" => Atom.to_string(event.__struct__),
              "workflow_event" => event
            })
            |> repo.update()
        end
    end
  end
end
