defmodule Spooks.SpooksCheckpointRunner do
  @moduledoc """
  The SpooksCheckpointRunner module is responsible for running agentic workflows.
  """
  use Task, restart: :permanent

  require Logger

  import Ecto.Query

  alias Spooks.WorkflowEngine
  alias Spooks.Schema.WorkflowCheckpoint
  alias Spooks.Checkpoint.SpookCheckpoints

  @doc """
  Starts the SpooksCheckpointRunner task with the provided options. This task should be run on each node.

  The repo is required for agents that saved their state to checkpoints and have timed out.
  The check time is the number of seconds between checks for agents to run. It is OPTIONAL and defaults to 60 minutes.
  The agent timeout is the number of minutes after which an agent checkpoint is considered stale. It is OPTIONAL and defaults to 60 minutes.
  """
  def start_link(opts) do
    Logger.info("start link called for SpooksCheckpointRunner #{inspect(opts)}")

    Task.start_link(__MODULE__, :run, [
      opts[:repo],
      opts[:checkpoint_timeout],
      opts[:check_time_in_minutes]
    ])
  end

  @doc """
  Checks for checkpoints that need to be resumed ON THIS NODE and tries to resume them.
  """
  def run(repo, checkpoint_timeout, check_time_in_minutes) do
    Logger.info("init called for SpooksCheckpointRunner #{inspect(check_time_in_minutes)}")
    minutes = check_time_in_minutes || 60
    Process.sleep(1000 * 60 * minutes)

    get_expired_checkpoints(repo)
    |> Enum.map(fn checkpoint ->
      repo.delete(checkpoint)
    end)

    get_timed_out_checkpoints(repo, checkpoint_timeout)
    |> Enum.map(fn checkpoint ->
      try do
        event = SpookCheckpoints.get_checkpoint_event(checkpoint)
        workflow_context = SpookCheckpoints.get_workflow_context(checkpoint)
        WorkflowEngine.run_step(workflow_context, event)
      rescue
        e ->
          Logger.error("Error running checkpoint: #{checkpoint.id} with error: #{inspect(e)}")
      end
    end)
  end

  def get_expired_checkpoints(repo) do
    now = NaiveDateTime.utc_now()

    from(
      c in WorkflowCheckpoint,
      where: c.checkpoint_timeout < ^now
    )
    |> repo.all()
  end

  def get_timed_out_checkpoints(repo, checkpoint_timeout) do
    timeout = NaiveDateTime.add(NaiveDateTime.utc_now(), checkpoint_timeout * -1, :minute)

    from(
      c in WorkflowCheckpoint,
      where: c.updated_at < ^timeout
    )
    |> repo.all()
  end
end
