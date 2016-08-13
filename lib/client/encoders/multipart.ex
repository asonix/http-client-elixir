defmodule Client.Encoders.Multipart do
  @behaviour Client.Encoders

  def headers, do: %{}
  def encode(payload), do: FormData.create(payload, :multipart)
  def encode!(payload), do: FormData.create!(payload, :multipart)
end
