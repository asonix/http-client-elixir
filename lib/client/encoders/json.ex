defmodule Client.Encoders.JSON do
  @behaviour Client.Encoders

  def headers, do: %{"Content-Type" => "application/json"}
  def encode(payload), do: Poison.encode(payload)
  def encode!(payload), do: Poison.encode!(payload)
end
