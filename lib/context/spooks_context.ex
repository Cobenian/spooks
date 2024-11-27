defmodule Spooks.Context.SpooksContext do
  @derive Jason.Encoder
  defstruct workflow_identifier: nil,
            workflow_module: nil,
            repo: nil,
            llm: nil,
            checkpoint_timeout_in_minutes: nil,
            assigns: %{}

  @doc """
  Creates a new context struct, prefer this over initizializing the struct directly.
  """
  def new(workflow_module, repo, llm \\ nil) do
    %__MODULE__{
      workflow_identifier: Ecto.UUID.generate(),
      workflow_module: workflow_module,
      repo: repo,
      llm: llm
    }
  end

  @doc """
  Function for putting your custom data into the context.
  """
  def put_data(%__MODULE__{} = context, keys, value) when is_list(keys) do
    put_in(context, [Access.key(:assigns)] ++ keys, value)
  end

  def put_data(%__MODULE__{} = context, key, value) do
    put_data(context, [key], value)
  end

  @doc """
  Function for getting your custom data from the context.
  """
  def get_data(%__MODULE__{} = context, keys) when is_list(keys) do
    get_in(context, [Access.key(:assigns)] ++ keys)
  end

  def get_data(%__MODULE__{} = context, key) do
    get_data(context, [key])
  end
end
