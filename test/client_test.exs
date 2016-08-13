defmodule ClientTest do
  use ExUnit.Case
  doctest Client

  import Client

  @generic_payload %{
    "key" => "value",
    "key2" => [
      "value1",
      "value2",
      "value3"
    ]
  }

  def prepare_conn(conn) do
    parsers_opts = Plug.Parsers.init(parsers: [:json, :urlencoded, :multipart],
                                     pass: ["*/*"],
                                     json_decoder: Poison)

    conn
    |> Plug.Parsers.call(parsers_opts)
    |> Plug.Conn.fetch_query_params
    |> Plug.Conn.resp(200, Poison.encode!(@generic_payload))
  end

  def assert_request(conn, path, method, params, headers) do
    conn = prepare_conn(conn)

    assert conn.request_path == path
    assert conn.method == method

    if !is_nil(params), do: assert conn.params == params

    Enum.each(headers, fn header ->
      assert header in conn.req_headers
    end)

    conn
  end

  setup do
    bypass = Bypass.open
    url = "localhost:#{bypass.port}/"
    {:ok, bypass: bypass, url: url}
  end

  test "urlencoded get", %{bypass: bypass, url: url} do
    Bypass.expect bypass, fn conn ->
      assert_request(
        conn,
        "/test",
        "GET",
        @generic_payload,
        [{"header", "header"}]
      )
    end

    assert @generic_payload == do_request!(
      "#{url}test",
      @generic_payload,
      %{"header" => "header"},
      Client.Encoders.GETURLEncoded,
      Client.Decoders.JSON,
      &Client.get!(&1, &2, &3)
    )
  end

  test "json post", %{bypass: bypass, url: url} do
    Bypass.expect bypass, fn conn ->
      assert_request(
        conn,
        "/test",
        "POST",
        @generic_payload,
        [{"header", "header"}]
      )
    end

    assert @generic_payload == do_request!(
      "#{url}test",
      @generic_payload,
      %{"header" => "header"},
      Client.Encoders.JSON,
      Client.Decoders.JSON,
      &Client.post!(&1, &2, &3)
    )
  end

  test "urlencoded patch", %{bypass: bypass, url: url} do
    Bypass.expect bypass, fn conn ->
      assert_request(
        conn,
        "/test",
        "PATCH",
        @generic_payload,
        [{"header", "header"}]
      )
    end

    assert {:ok, @generic_payload} == do_request(
      "#{url}test",
      @generic_payload,
      %{"header" => "header"},
      Client.Encoders.URLEncoded,
      Client.Decoders.JSON,
      &Client.patch(&1, &2, &3)
    )
  end

  test "multipart put", %{bypass: bypass, url: url} do
    Bypass.expect bypass, fn conn ->
      assert_request(
        conn,
        "/test",
        "PUT",
        @generic_payload,
        [{"header", "header"}]
      )
    end

    assert {:ok, @generic_payload} == do_request(
      "#{url}test",
      @generic_payload,
      %{"header" => "header"},
      Client.Encoders.Multipart,
      Client.Decoders.JSON,
      &Client.put(&1, &2, &3)
    )
  end

  test "json delete", %{bypass: bypass, url: url} do
    Bypass.expect bypass, fn conn ->
      assert_request(
        conn,
        "/test",
        "DELETE",
        nil,
        [{"header", "header"}]
      )
    end

    assert @generic_payload == do_request!(
      "#{url}test",
      @generic_payload,
      %{"header" => "header"},
      Client.Encoders.NilEncoder,
      Client.Decoders.JSON,
      &Client.delete!(&1, &2, &3)
    )
  end
end
