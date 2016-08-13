# Client

HTTPClient is a simple wrapper around HTTPoison using Poison and
HTTPoisonFormData to format payloads.

## Installation

The package can be installed as:

  1. Add `http_client` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:http_client, "~> 0.1.0"}]
    end
    ```

  2. Ensure `client` is started before your application:

    ```elixir
    def application do
      [applications: [:client]]
    end
    ```

## Configuration
none...

## Usage

It is important to understand how this client works in order to properly use it.
It provides two implementations of a single function `do_request/6`, which takes
the arguments explained below:

| Argument   | description |
| ---------- | ----------- |
| `href`     | The URL of the resource to be queried |
| `payload`  | A Map, Struct, or List to be sent to the server |
| `headers`  | The headers to be sent with the query |
| `encoder`  | This is an encoder from the Client package, a list of encoders is provided below |
| `decoder`  | This is a decoder from the Client package, a list of decoders is proved below |
| `action`   | This is an HTTPoison verb. Usage defined below |

### Example
```elixir
data = Client.do_request(
  "https://httpbin.org",
  %{"key" => "value", "key2" => ["value1", "value2"]},
  %{"Header" => "Header/Value"},
  Client.Encoders.JSON,
  Client.Decoders.JSON,
  &Client.post(&1, &2, &3)
)

assert data == {
  :ok,
  %{
    "args" => %{},
    "data" => "{\"key2\":[\"value1\",\"value2\"],\"key\":\"value\"}",
    "files" => %{},
    "form" => %{},
    "headers" => %{
      "Accept" => "application/json",
      "Content-Length" => "42",
      "Content-Type" => "application/json",
      "Header" => "Header/Value",
      "Host" => "httpbin.org",
      "User-Agent" => "hackney/1.6.1"
    },
    "json" => %{
      "key" => "value",
      "key2" => ["value1", "value2"]
    },
    "origin" => "72.182.43.183",
    "url" => "https://httpbin.org/post"
  }
}
```

### Encoders
#### Provided Encoders
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
#### Extension
You can provide your own encoders by making a module that implements the
`Client.Encoders` behaviour.

##### Example
```elixir
defmodule MyCustomEncoder do
  @behaviour Client.Encoders

  def headers, do: %{"Content-Type" => "application/custom-data"}
  def encode(payload), do: MyEncoder.encode(payload)
  def encode!(payload), do: MyEncoder.encode!(payload)
end
```

See the `Client.Encoders` behaviour for exact typespecs.

### Deocoders
#### Provided Decoders
 - JSON
    This uses Poison to decode responses from a server. It sets a custom
    `Accept` header to `application/json` so the server knows what data
    to respond with.
#### Extension
You can provide your own decoders by making a module that implements the
`Client.Decoders` behaviour.

##### Example
```elixir
defmodule MyCustomDecoder do
  @behaviour Client.Encoders

  def headers, do: %{"Accept" => "application/custom-data"}
  def decode(data), do: MyDecoder.decode(data)
  def decode!(data), do: MyDecoder.decode!(data)
end
```

See the `Client.Decoders` behaviour for exact typespecs.

### Actions
Actions are the part that actually make the HTTP Request, if that is what you
choose to do with this library. It is failry generic. Some actions are provided.
#### Provided Actions
 - `Client.get/3` / `Client.get!/3`
 - `Client.post/3` / `Client.post!/3`
 - `Client.patch/3` / `Client.patch!/3`
 - `Client.put/3` / `Client.put!/3`
 - `Client.delete/3` / `Client.delete!/3`
The provided actions are all simple wrappers around HTTPoison to make the
arguments resemble what the callback requires in `do_request/6` and
`do_request!/6`

#### Notes
When using `do_request/6`, your actions all need to return a tuple of the format
`{:ok, data}` or `{:error, reason}`, any other formats will not be properly
handled by `do_request/6`.

When using `do_request!/6`, your actions must all return `data` directly,
outside of the tuple used in the safer version. The reason for this is we expect
errors in this case to be raised rather than returned.

### Helpers
You can make the process of calling functions like these easier if you know
about how you want to interact with the server.
```elixir
def get_json(href, payload, headers)
  do_request(href, payload, headers,
    Client.Encoders.GETURLEncoded,
    Client.Decoders.JSON,
    &Client.get(&1, &2, &3)
  )
end

def post_json(href, payload, headers)
  do_request(href, payload, headers,
    Client.Encoders.JSON,
    Client.Decoders.JSON,
    &Client.post(&1, &2, &3)
  )
end

... # etc

def delete_json(href, headers)
  do_request(href, %{}, headers,
    Client.Encoders.NilEncoder,
    Client.Decoders.JSON,
    &Client.delete(&1, &2, &3)
  )
end
```
Helper functions like these make working with HTTP incredibly easy.

## License
```
Copyright © 2016 Riley Trautman, <asonix.dev@gmail.com>

This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the LICENSE file for more details.
```
