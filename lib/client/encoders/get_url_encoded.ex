defmodule Client.Encoders.GETURLEncoded do
  @behaviour Client.Encoders

  def headers, do: %{}
  def encode(payload), do: FormData.create(payload, :url_encoded, get: true)
  def encode!(payload), do: FormData.create!(payload, :url_encoded, get: true)
end
