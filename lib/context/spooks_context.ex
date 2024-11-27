defmodule Spooks.Context.SpooksContext do
  @derive Jason.Encoder
  defstruct workflow_identifier: nil,
            workflow_module: nil,
            repo: nil,
            llm: nil,
            checkpoint_timeout_in_minutes: nil,
            assigns: %{}

  def new(workflow_module, repo, llm \\ nil) do
    %__MODULE__{
      workflow_identifier: Ecto.UUID.generate(),
      workflow_module: workflow_module,
      repo: repo,
      llm: llm
    }
  end

  def add_data(%__MODULE__{} = context, keys, value) when is_list(keys) do
    put_in(context.assigns, keys, value)
  end

  def add_data(%__MODULE__{} = context, key, value) do
    add_data(context.assigns, [key], value)
  end

  def get_data(%__MODULE__{} = context, keys) when is_list(keys) do
    get_in(context.assigns, keys)
  end

  def get_data(%__MODULE__{} = context, key) do
    get_data(context.assigns, [key])
  end
end
