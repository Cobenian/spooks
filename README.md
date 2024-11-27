# spooks
An agentic workflow framework in Elixir

## Installation

You must run an ecto migration to create the `spooks_workflow_checkpoints` table if you plan on using checkpoints.

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `spooks` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:spooks, "~> 0.1.0"}
  ]
end
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

```elixir
defmodule MyApp.MyCustomEvent do
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
def my_first_step(event, ctx) do
  ...
end

@step %Step{in: MyFirstEvent, out: nil}
def my_last_step(event, ctx) do
  {:ok, nil, ctx}
end
```

There are two built in events for `Spooks.Event.StartEvent` and `Spooks.Event.EndEvent`.

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
