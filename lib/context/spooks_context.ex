defmodule Spooks.Context.SpooksContext do
  defstruct workflow_identifier: nil,
            workflow_module: nil,
            repo: nil,
            llm: nil,
            checkpoint_timeout_in_minutes: nil

  def new(workflow_module, repo, llm \\ nil) do
    %__MODULE__{
      workflow_identifier: Ecto.UUID.generate(),
      workflow_module: workflow_module,
      repo: repo,
      llm: llm
    }
  end
end
