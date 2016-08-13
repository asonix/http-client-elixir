defmodule Client.Encoders do
  @moduledoc """
  # Provided Encoders
   - GETURLEncoded
      This uses FormData to prepare a url-encoded payload for GET requests, it
      does not set custom headers because HTTPoison and Hackney do this
      automatically.
   - JSON
      This uses Poison to prepare a binary payload for POST, PATCH, and PUT
      requests, it sets a custom `Content-Type` header to `application/json`.
   - Multipart
      This uses FormData to prepare a multipart payload for POST, PATCH, PUT
      requests. It does not set custom headers because HTTPoison and Hackney do
      this automatically.
   - NilEncoder
      This does not encode any data, it is only useful for documentation purposes
      when using HTTPoison's delete/2 function, since DELETE requests do not carry
      payloads.
   - URLEncoded
      This uses FormData to prepare a url-encoded payload for POST, PATCH< and PUT
      requests. It does not set custom headers because HTTPoison and Hackney do
      this automatically.

  ## Examples

      defmodule MyCustomEncoder do
        @behaviour Client.Encoders

        def headers, do: %{"Content-Type" => "application/custom-data"}
        def encode(payload), do: MyEncoder.encode(payload)
        def encode!(payload), do: MyEncoder.encode!(payload)
      end

  """

  @type payload :: map | list | struct
  @type encoded :: {:ok, any} | {:error, any}

  @callback headers :: map
  @callback encode(payload) :: encoded
  @callback encode!(payload) :: any
end
