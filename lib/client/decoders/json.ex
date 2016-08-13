defmodule Client.Decoders.JSON do
  @behaviour Client.Decoders

  def headers, do: %{"Accept" => "application/json"}
  def decode(payload), do: Poison.decode(payload)
  def decode!(payload), do: Poison.decode!(payload)
end
