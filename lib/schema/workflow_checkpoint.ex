defmodule Spooks.Schema.WorkflowCheckpoint do
  use Ecto.Schema
  import Ecto.Changeset

  schema "spooks_workflow_checkpoints" do
    field(:workflow_identifier, :string)
    field(:workflow_module, :string)
    field(:workflow_context, :map)
    field(:workflow_event_module, :string)
    field(:workflow_event, :map)
    field(:checkpoint_timeout, :naive_datetime)

    timestamps()
  end

  def create_changeset(workflow_checkpoint, attrs) do
    workflow_checkpoint
    |> cast(attrs, [
      :workflow_identifier,
      :workflow_module,
      :workflow_context,
      :workflow_event_module,
      :workflow_event,
      :checkpoint_timeout
    ])
    |> validate_required([
      :workflow_identifier,
      :workflow_module,
      :workflow_context,
      :workflow_event_module,
      :workflow_event,
      :checkpoint_timeout
    ])
  end

  def update_changeset(workflow_checkpoint, attrs) do
    workflow_checkpoint
    |> cast(attrs, [
      :workflow_context,
      :workflow_event_module,
      :workflow_event
    ])
    |> validate_required([
      :workflow_context,
      :workflow_event_module,
      :workflow_event
    ])
  end
end
