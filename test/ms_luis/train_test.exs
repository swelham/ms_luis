defmodule MsLuisTest.Train do
  @moduledoc false
  
  use ExUnit.Case
  doctest MsLuis.Train

  import MsLuisTest.TestMacros

  alias MsLuis.Train

  setup do
    bypass = Bypass.open([port: 8080])

    {:ok, bypass: bypass}
  end

  test "get_status/2 should return the application training status", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/luis/api/v2.0/apps/123/versions/0.1/train"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, "[{\"modelId\":\"456\"}]")
    end

    {:ok, result} = Train.get_status("123", "0.1")

    assert result == [%{"modelId" => "456"}]
  end

  test "train_version/2 should send a valid train version request", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "POST"
      assert conn.request_path == "/luis/api/v2.0/apps/123/versions/0.1/train"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, "[{\"modelId\":\"456\"}]")
    end

    {:ok, result} = Train.train_version("123", "0.1")

    assert result == [%{"modelId" => "456"}]
  end
end