defmodule Client.Decoders do
  @moduledoc """
  # Provided Decoders
   - `JSON`

      This uses Poison to decode responses from a server. It sets a custom
      `Accept` header to `application/json` so the server knows what data
      to respond with.

  ## Examples

      defmodule MyCustomDecoder do
        @behaviour Client.Encoders

        def headers, do: %{"Accept" => "application/custom-data"}
        def decode(data), do: MyDecoder.decode(data)
        def decode!(data), do: MyDecoder.decode!(data)
      end

  """

  @type decoded :: {:ok, any} | {:error, any}
  @callback headers :: map

  @callback decode(binary) :: decoded
  @callback decode!(binary) :: any
end
