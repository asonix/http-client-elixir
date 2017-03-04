defmodule Client do
  @moduledoc """
  The client module contains two functions of note, `do_request/6` and
  `do_request!/6` which perform HTTP actions as well as encoding and decoding
  data and setting headers involved in the request.

  ## Actions
  
  Actions are the part that actually make the HTTP Request, if that is what you
  choose to do with this library. It is failry generic. Some actions are provided.

  ### Provided Actions
   - `Client.get/3` / `Client.get!/3`
   - `Client.post/3` / `Client.post!/3`
   - `Client.patch/3` / `Client.patch!/3`
   - `Client.put/3` / `Client.put!/3`
   - `Client.delete/3` / `Client.delete!/3`

  The provided actions are all simple wrappers around HTTPoison to make the
  arguments resemble what the callback requires in `do_request/6` and
  `do_request!/6`
  """

  alias HTTPoison.Response

  defmodule ResponseNot200Error do
    defexception [:message]

    def exception(%Response{status_code: status}) do
      msg = "status code: #{status}"

      {:error, %__MODULE__{message: msg}}
    end
    def exception(value) do
      msg = "expected %HTTPoison.Response{}, got: #{inspect value}"

      {:error, %__MODULE__{message: msg}}
    end
  end

  def get(href, payload, headers),
    do: HTTPoison.get(href, headers, payload)

  def post(href, payload, headers),
    do: HTTPoison.post(href, payload, headers)

  def patch(href, payload, headers),
    do: HTTPoison.patch(href, payload, headers)

  def put(href, payload, headers),
    do: HTTPoison.put(href, payload, headers)

  def delete(href, _payload, headers),
    do: HTTPoison.delete(href, headers)

  def get!(href, payload, headers),
    do: HTTPoison.get!(href, headers, payload)

  def post!(href, payload, headers),
    do: HTTPoison.post!(href, payload, headers)

  def patch!(href, payload, headers),
    do: HTTPoison.patch!(href, payload, headers)

  def put!(href, payload, headers),
    do: HTTPoison.put!(href, payload, headers)

  def delete!(href, _payload, headers),
    do: HTTPoison.delete!(href, headers)

  @doc """
  Sequences calls to encoder, action, and decoder to perform HTTPoison requests.

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

  ## Notes

  When using `do_request/6`, your actions all need to return a tuple of the format
  `{:ok, data}` or `{:error, reason}`, any other formats will not be properly
  handled by `do_request/6`.

  ## Examples

      data = Client.do_request(
        "https://httpbin.org/post",
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
          "data" => "{\\"key2\\":[\\"value1\\",\\"value2\\"],\\"key\\":\\"value\\"}",
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
          "origin" => "127.0.0.1",
          "url" => "https://httpbin.org/post"
        }
      }

      iex> Client.do_request("a.com", %{"key" => "value"}, %{}, Client.Encoders.JSON, Client.Decoders.JSON, fn _href, payload, _headers -> {:ok, %HTTPoison.Response{status_code: 200, body: payload}} end)
      {:ok, %{"key" => "value"}}

  """
  def do_request(href, payload, headers, encoder, decoder, action) do
    with {:ok, payload} <- encoder.encode(payload) do
      headers = encoder.headers
        |> Map.merge(decoder.headers)
        |> Map.merge(headers)

      with {:ok, response} <- action.(href, payload, headers),
        do: handle_response(response, decoder)
    end
  end

  @doc """
  Aggressive version of `do_request/6`. Aggressive means raising errors rather
  than returning error structs.

  ## Notes

  When using `do_request!/6`, your actions must all return `data` directly,
  outside of the tuple used in the safer version. The reason for this is we expect
  errors in this case to be raised rather than returned.

  ## Examples

      iex> Client.do_request!("a.com", %{"key" => "value"}, %{}, Client.Encoders.JSON, Client.Decoders.JSON, fn _href, payload, _headers -> %HTTPoison.Response{status_code: 200, body: payload} end)
      %{"key" => "value"}

  """
  def do_request!(href, payload, headers, encoder, decoder, action) do
    payload = encoder.encode!(payload)
    headers = encoder.headers
      |> Map.merge(decoder.headers)
      |> Map.merge(headers)

    href
    |> action.(payload, headers)
    |> handle_response!(decoder)
  end

  defp handle_response(%Response{status_code: status, body: body}=response, decoder) do
    cond do
      status in [200, 201] ->
        decoder.decode(body)
      status == 204 ->
        {:ok, :no_content}
      true ->
        ResponseNot200Error.exception(response)
    end
  end

  defp handle_response!(%Response{status_code: status, body: body}=response, decoder) do
    cond do
      status in [200, 201] ->
        decoder.decode!(body)
      status == 204 ->
        :no_content
      true ->
        with {:error, error} <- ResponseNot200Error.exception(response),
          do: raise error
    end
  end
end
