defmodule Spooks.SpooksMermaidDiagrams do
  @moduledoc """
  Module for generating mermaid diagrams from a workflow module.

  You need to have mermaid.js included in your project to render the diagrams. Add it using your package manager (npm, yarn, poetry, etc).

  You also need a live view javascript hook to render the diagrams.
  In `hooks.js` you can add the following code:

  ```javascript
  import mermaid from "mermaid";

  let Hooks = {  }

  Hooks.Mermaid = {
    mounted() {
      this.renderMermaid();
    },
    updated() {
      this.renderMermaid();
    },
    renderMermaid() {
      mermaid.run(undefined, this.el.querySelectorAll('.mermaid'));
    }
  };

  export default Hooks
  ```
  Then in your heex files you can include the diagram like this:

  Example:
      <div phx-hook="Mermaid" id="my-diagram-id">
        <div markdown={1}>
          <pre class="mermaid">
            <%= @diagram_text %>
          </pre>
        </div>
      </div>

  """

  @doc """
  Generates a mermaid diagram from a workflow module.

  Example:
      iex> Spooks.SpooksMermaidDiagrams.get_spooks_diagram_text(Spooks.Sample.SampleWorkflow)
    
  """
  def get_spooks_diagram_text(workflow_module_name) when is_atom(workflow_module_name) do
    apply(workflow_module_name, :steps, [])
    |> get_spooks_diagram_text_from_steps()
  end

  @doc """
  Generates a mermaid diagram from a list of steps.
  You can get the steps from a workflow by calling the steps function on the workflow.

  Example:
      iex> steps = Spooks.Sample.SampleWorkflow.steps()
      iex> Spooks.SpooksMermaidDiagrams.get_spooks_diagram_text_from_steps(steps)
  """
  def get_spooks_diagram_text_from_steps(steps) when is_list(steps) do
    text =
      """
        stateDiagram-v2
          direction LR
      """

    text =
      Enum.reduce(steps, text, fn step, acc ->
        new_text =
          if is_start_event(step) do
            """
                [*] --> #{mermaid_name(step.in)}
                #{mermaid_name(step.in, step.ai)} --> #{mermaid_name(step.out)}
            """
          else
            if is_list(step.out) do
              Enum.reduce(step.out, "", fn out, acc ->
                acc <>
                  """
                      #{mermaid_name(step.in, step.ai)} --> #{mermaid_name(out)}
                  """
              end)
            else
              """
                  #{mermaid_name(step.in, step.ai)} --> #{mermaid_name(step.out)}
              """
            end
          end

        acc <> new_text
      end)

    text =
      text <>
        """

            classDef aistage fill:pink,color:#fff,stroke-width:4px,stroke:black
        """

    text
  end

  defp mermaid_name(nil) do
    "[*]"
  end

  defp mermaid_name(module) do
    module
    |> Atom.to_string()
    |> String.split(".")
    |> List.last()
  end

  defp mermaid_name(module, true) do
    name =
      module
      |> Atom.to_string()
      |> String.split(".")
      |> List.last()

    "#{name}:::aistage"
  end

  defp mermaid_name(module, _) do
    mermaid_name(module)
  end

  defp is_start_event(step) do
    step.in == Spooks.Event.StartEvent
  end
end
