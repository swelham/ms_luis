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

    test "get_info/1 should return the application info", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/luis/api/v2.0/apps/123"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, "{\"id\":\"123\",\"name\":\"test_app\"}")
    end

    {:ok, info} = Apps.get_info("123")

    assert info == %{"id" => "123", "name" => "test_app"}
  end

  test "get_settings/1 should return the application settings", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/luis/api/v2.0/apps/123/settings"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, "{\"id\":\"123\",\"public\":true}")
    end

    {:ok, settings} = Apps.get_settings("123")

    assert settings == %{"id" => "123", "public" => true}
  end

  test "get_usage_scenarios/0 should return the application usage scenarios", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/luis/api/v2.0/apps/usagescenarios"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, "[\"IoT\", \"Bot\"]")
    end

    {:ok, scenarios} = Apps.get_usage_scenarios()

    assert scenarios == ["IoT", "Bot"]
  end

  test "get_prebuilt_domains/0 should return a list of available prebuilt domains", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/luis/api/v2.0/apps/customprebuiltdomains"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, "[{\"name\":\"weather\"}]")
    end

    {:ok, domains} = Apps.get_prebuilt_domains()

    assert domains == [%{"name" => "weather"}]
  end

  test "get_prebuilt_domains/1 should return a list of available prebuilt domains for a given culture", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/luis/api/v2.0/apps/customprebuiltdomains/en-us"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, "[{\"name\":\"weather\"}]")
    end

    {:ok, domains} = Apps.get_prebuilt_domains("en-us")

    assert domains == [%{"name" => "weather"}]
  end

  test "get_assistants/0 should return a list of personal assitant applications", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/luis/api/v2.0/apps/assistants"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, "{\"endpointKeys\":[],\"endpointUrls\":{\"English\":\"EnglishDummyURL\"}}")
    end

    {:ok, assistants} = Apps.get_assistants()

    assert assistants == %{
      "endpointKeys" => [],
      "endpointUrls" => %{
        "English" => "EnglishDummyURL"
      }
    }
  end

  test "get/0 should return a list the users applications", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/luis/api/v2.0/apps"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, "[{\"id\":\"123\"}]")
    end

    {:ok, apps} = Apps.get()

    assert apps == [%{"id" => "123"}]
  end

  test "get/1 should return a limited list the users applications", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/luis/api/v2.0/apps"
      assert conn.query_string == "skip=10&take=5"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, "[{\"id\":\"123\"}]")
    end

    {:ok, apps} = Apps.get(%{skip: 10, take: 5})

    assert apps == [%{"id" => "123"}]
  end

  test "import/1 should send a valid import application request", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert conn.method == "POST"
      assert conn.request_path == "/luis/api/v2.0/apps/import"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == "{\"name\":\"test_app\"}"

      conn
      |> Plug.Conn.put_resp_content_type("text/plain")
      |> Plug.Conn.send_resp(201, "123")
    end

    {:ok, app_id} = Apps.import(%{name: "test_app"})

    assert app_id == "123"
  end

  test "import/2 should send a valid import application request with the appName query param", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert conn.method == "POST"
      assert conn.request_path == "/luis/api/v2.0/apps/import"
      assert conn.query_string == "appName=test_app_query"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == "{\"name\":\"test_app\"}"

      conn
      |> Plug.Conn.put_resp_content_type("text/plain")
      |> Plug.Conn.send_resp(201, "123")
    end

    {:ok, app_id} = Apps.import(%{name: "test_app"}, "test_app_query")

    assert app_id == "123"
  end

  test "publish/2 should send a valid publish application request", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert conn.method == "POST"
      assert conn.request_path == "/luis/api/v2.0/apps/123/publish"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == "{\"versionId\":\"0.1\"}"

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(201, "{\"endpointUrl\":\"TestURL\"}")
    end

    {:ok, response} = Apps.publish("123", %{versionId: "0.1"})

    assert response == %{"endpointUrl" => "TestURL"}
  end

  test "rename/2 should send a valid rename application request", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert conn.method == "PUT"
      assert conn.request_path == "/luis/api/v2.0/apps/123"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == "{\"name\":\"new_name\"}"

      Plug.Conn.send_resp(conn, 200, "")
    end

    assert :ok == Apps.rename("123", %{name: "new_name"})
  end
end