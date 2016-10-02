defmodule Client.Decoders.NilDecoder do
  @behaviour Client.Decoders

  def headers, do: %{}
  def decode(_payload), do: {:ok, %{}}
  def decode!(_payload), do: %{}
end
