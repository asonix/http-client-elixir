defmodule Client.Encoders.URLEncoded do
  @behaviour Client.Encoders

  def headers, do: %{}
  def encode(payload), do: FormData.create(payload, :url_encoded)
  def encode!(payload), do: FormData.create!(payload, :url_encoded)
end
