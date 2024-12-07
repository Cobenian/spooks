defmodule Spooks.SpooksAgentRunner do
  @moduledoc """
  The SpooksAgentsRunner module is responsible for running agentic workflows.
  """
  use Task, restart: :permanent

  require Logger

  alias Spooks.Context.SpooksContext
  alias Spooks.WorkflowEngine

  @doc """
  Starts the SpooksAgentsRunner task with the provided options. This task should be run on each node.

  The repo is required for agents that save their state to checkpoints.
  The run time is the number of seconds between checks for agents to run. It is OPTIONAL and defaults to 60 minutes.
  """
  def start_link(opts) do
    Logger.info("start link called for SpooksAgentsRunner #{inspect(opts)}")

    Task.start_link(__MODULE__, :run, [
      opts[:workflow_module_name],
      opts[:repo],
      opts[:llm],
      opts[:check_time_in_minutes],
      opts[:checkpoints_enabled]
    ])
  end

  @doc """
  Checks for jobs that need to be killed ON THIS NODE and tries to kill them.
  """
  def run(workflow_module_name, repo, llm, check_time_in_minutes, checkpoints_enabled) do
    Logger.info("init called for SpooksAgentsRunner #{inspect(check_time_in_minutes)}")
    minutes = check_time_in_minutes || 60
    Process.sleep(1000 * 60 * minutes)

    ctx = SpooksContext.new(workflow_module_name, repo, llm, checkpoints_enabled)
    WorkflowEngine.run_workflow(ctx)
  end
end
