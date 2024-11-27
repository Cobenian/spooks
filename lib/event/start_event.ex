defmodule Spooks.Event.StartEvent do
  @derive {Jason.Encoder, only: [:__struct__, :data]}
  defstruct data: nil
end
