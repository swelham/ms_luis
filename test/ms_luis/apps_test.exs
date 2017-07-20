defmodule MsLuisTest.Apps do
  use ExUnit.Case
  doctest MsLuis.Apps

  import MsLuisTest.TestMacros

  alias MsLuis.Apps

  setup do
    bypass = Bypass.open([port: 8080])

    {:ok, bypass: bypass}
  end

  test "add/1 should send a valid create application request", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert conn.method == "POST"
      assert conn.request_path == "/luis/api/v2.0/apps"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == "{\"name\":\"test app\",\"culture\":\"en-us\"}"

      conn
      |> Plug.Conn.put_resp_content_type("text/plain")
      |> Plug.Conn.send_resp(201, "123")
    end

    {:ok, id} = Apps.add(%{name: "test app", culture: "en-us"})

    assert id == "123"
  end

  test "add_prebuilt/1 should send a valid add prebuilt application request", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert conn.method == "POST"
      assert conn.request_path == "/luis/api/v2.0/apps/customprebuiltdomains"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == "{\"domainName\":\"Web\",\"culture\":\"en-us\"}"

      conn
      |> Plug.Conn.put_resp_content_type("text/plain")
      |> Plug.Conn.send_resp(201, "123")
    end

    {:ok, id} = Apps.add_prebuilt(%{domain_name: "Web", culture: "en-us"})

    assert id == "123"
  end
  
  test "delete/1 should send a valid delete application request", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "DELETE"
      assert conn.request_path == "/luis/api/v2.0/apps/123"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      Plug.Conn.send_resp(conn, 200, "")
    end

    assert :ok == Apps.delete("123")
  end
  
  test "get_query_logs/1 should return the query logs for a given application", %{bypass: bypass} do
    req_response = File.read!("test/fixtures/query_log_response.txt")

    Bypass.expect bypass, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/luis/api/v2.0/apps/123/queryLogs"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      Plug.Conn.send_resp(conn, 200, req_response)
    end

    {:ok, logs} = Apps.get_query_logs("123")

    assert logs == [%{
      query: "turn the lights off",
      datetime: "07/19/2017 12:55:20",
      response: %{
        "query" => "turn the lights off",
        "intents" => [
          %{
            "intent" => "lights_off",
            "score" => 0.1140182
          },
          %{
            "intent" => "None",
            "score" => 0.0388641022
          }
        ],
        "entities" => []
      }
    }]
  end
  
  test "get_query_logs/2 should return the raw query logs for a given application", %{bypass: bypass} do
    req_response = File.read!("test/fixtures/query_log_response.txt")

    Bypass.expect bypass, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/luis/api/v2.0/apps/123/queryLogs"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      Plug.Conn.send_resp(conn, 200, req_response)
    end

    {:ok, raw_logs} = Apps.get_query_logs("123", output: :raw)

    assert raw_logs == req_response
  end

  test "get_query_logs/2 should return unknown output type for invalid output option", %{bypass: bypass} do
    req_response = File.read!("test/fixtures/query_log_response.txt")

    Bypass.expect bypass, fn conn ->
      Plug.Conn.send_resp(conn, 200, req_response)
    end

    assert {:error, "':none' is not a valid output type"} = Apps.get_query_logs("123", output: :none)
  end

  test "get_cultures/0 should return the list of available cultures", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/luis/api/v2.0/apps/cultures"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, "[{\"name\":\"English\",\"code\":\"en-us\"}]")
    end

    {:ok, cultures} = Apps.get_cultures()

    assert cultures == [%{"name" => "English", "code" => "en-us"}]
  end

  test "get_domains/0 should return the list of available domains", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/luis/api/v2.0/apps/domains"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, "[\"Business\",\"Communication\"]")
    end

    {:ok, domains} = Apps.get_domains()

    assert domains == ["Business", "Communication"]
  end
end