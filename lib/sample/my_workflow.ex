defmodule MyWorkflow do
  use Spooks.Workflow

  @step :first_step
  def first_step do
    IO.puts("First step")
  end

  @step :second_step
  def second_step do
    IO.puts("Second step")
  end
end
