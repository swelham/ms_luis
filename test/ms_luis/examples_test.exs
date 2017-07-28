defmodule MsLuisTest.Examples do
  use ExUnit.Case
  doctest MsLuis.Examples

  import MsLuisTest.TestMacros

  alias MsLuis.Examples

  setup do
    bypass = Bypass.open([port: 8080])

    {:ok, bypass: bypass}
  end

  test "add_label/3 should send a valid add label request", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert conn.method == "POST"
      assert conn.request_path == "/luis/api/v2.0/apps/123/versions/0.1/example"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})
      assert body == "{\"text\":\"test\"}"

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(201, "{\"ExampleId\":-11}")
    end

    {:ok, result} = Examples.add_label("123", "0.1", %{text: "test"})

    assert result == %{"ExampleId" => -11}
  end

  test "add_labels/3 should send a valid add batch labels request", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert conn.method == "POST"
      assert conn.request_path == "/luis/api/v2.0/apps/123/versions/0.1/examples"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})
      assert body == "[{\"text\":\"test\"}]"

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(201, "[{\"value\":{\"ExampleId\":-11}}]")
    end

    {:ok, result} = Examples.add_labels("123", "0.1", [%{text: "test"}])

    assert result == [%{"value" => %{"ExampleId" => -11}}]
  end

  test "delete_label/3 should send a valid delete label request", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "DELETE"
      assert conn.request_path == "/luis/api/v2.0/apps/123/versions/0.1/examples/-11"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      conn
      |> Plug.Conn.put_resp_content_type("text/plain")
      |> Plug.Conn.send_resp(200, "")
    end

    assert :ok == Examples.delete_label("123", "0.1", "-11")
  end

  test "get_labels_to_review/2 should return a list of labeled examples for review", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/luis/api/v2.0/apps/123/versions/0.1/examples"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, "[{\"id\":-12}]")
    end

    {:ok, results} = Examples.get_labels_to_review("123", "0.1")

    assert results == [%{"id" => -12}]
  end
  
  test "get_labels_to_review/3 should return a limited list of labeled examples for review", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/luis/api/v2.0/apps/123/versions/0.1/examples"
      assert conn.query_string == "skip=10&take=5"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, "[{\"id\":-12}]")
    end

    {:ok, results} = Examples.get_labels_to_review("123", "0.1", %{skip: 10, take: 5})

    assert results == [%{"id" => -12}]
  end

end