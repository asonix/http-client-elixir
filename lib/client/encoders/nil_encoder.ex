defmodule Client.Encoders.NilEncoder do
  @behaviour Client.Encoders

  def headers, do: %{}
  def encode(_data), do: {:ok, nil}
  def encode!(_data), do: nil
end
