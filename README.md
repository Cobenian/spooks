# spooks
An agentic workflow framework in Elixir

## Installation

You must run an ecto migration to create the `spooks_workflow_checkpoints` table if you plan on using checkpoints.

```elixir
defmodule MyApp.Repo.Migrations.AddSpooksTables do
  use Ecto.Migration

  def down do
    drop table("spooks_workflow_checkpoints")
  end

  def up do
    create table("spooks_workflow_checkpoints") do
      add :workflow_identifier, :string
      add :workflow_module, :string
      add :workflow_context, :map
      add :workflow_event_module, :string
      add :workflow_event, :map
      add :checkpoint_timeout, :naive_datetime

      timestamps()
    end

    create unique_index("spooks_workflow_checkpoints", [:workflow_identifier])
  end
end

```

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `spooks` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:spooks, "~> 0.1.0"}
  ]
end
```

### Run agents in a supervision tree

In your `application.ex` file add an agent runner for each agent:

```elixir 
Supervisor.child_spec(
  {Spooks.SpooksAgentRunner,
    repo: MyApp.Repo,
    check_time_in_minutes: 1,
    workflow_module_name: MyApp.Agent.MyWorkflow,
    llm: MyApp.MyLLMClient,
    checkpoints_enabled: false
  },
  id: make_ref()
)
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/spooks>.

## Usage

Create your own workflow! Be sure you include the following line in your workflow module:

```elixir
use Spooks.Workflow
```

Create a struct for each event in your workflow. You can add whichever fields you like to your struct.

> [!NOTE]
> Note that all your events must `@derive Jason.Encoder` because they are saved to the database checkpoints.

```elixir
defmodule MyApp.MyCustomEvent do
  @derive Jason.Encoder
  defstruct []
end
```

In your workflow, add a function for each event. The name of the function *must* be the same as the event name only with underscores and with the final `_event` replaced with `_step`. Your function must take 2 arguments. The event and the context. It must return either the `{:ok, next_event, updated_ctx}` or `{:error, reason}` tuple.

For example:

```elixir
def my_custom_step(event, ctx) do
  next_event = ...
  udpated_ctx = ...
  {:ok, next_event, updated_ctx}
end
```

You _should_ add a `@step` annotation to your step functions. This is used for generating diagrams of your agentic workflow. 

`in` must be

- an event module name 

`out` can be 

- nil (the end of the agentic workflow)
- an event module name 
- a list of event module names (for branching)

```elixir
@step %Step{in: MyFirstEvent, out: MySecondEvent}
def my_first_step(event, ctx) do
  ...
end

@step %Step{in: MySecondEvent, out: [MyThirdEvent,StopEvent]}
def my_second_step(event, ctx) do
  ...
end

@step %Step{in: MyFirstEvent, out: nil}
def my_last_step(event, ctx) do
  {:ok, nil, ctx}
end
```

There are two built in events for `Spooks.Event.StartEvent` and `Spooks.Event.EndEvent`.

If you would like to add data or get data from the context you should use the following functions:

> [!HINT]
> You can also use a list of keys for `put_data` and `get_data` for nested data structures.

```elixir
@step %Step{in: MyFirstEvent, out: MySecondEvent}
def my_first_step(event, ctx) do
  new_ctx = Spooks.Context.SpooksContext.put_data(:greeting, "hello world!")
  {:ok, %MySecondEvent{}, new_ctx}
end

@step %Step{in: MySecondEvent, out: MyThirdEvent}
def my_second_step(event, ctx) do
  custom_greeting = Spooks.Context.SpooksContext.get_data(:greeting)
  IO.puts(custom_greeting)
  {:ok, %MyThirdEvent{}, ctx}
end
```

If you wish to save checkpoints after each step, pass in your repository to the workflow context.

```elixir
workflow = Spooks.Sample.SampleWorkflow
repo = MyApp.Repo

workflow_context = Spooks.Context.SpooksContext.new(workflow, repo)
Spooks.WorkflowEngine.run_workflow(workflow_context)
```

If you do not wish to save checkpoints:

```elixir
workflow = Spooks.Sample.SampleWorkflow
workflow_context = Spooks.Context.SpooksContext.new(workflow, nil)

Spooks.WorkflowEngine.run_workflow(workflow_context)
```


