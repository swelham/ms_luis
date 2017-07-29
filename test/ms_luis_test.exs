defmodule MsLuisTest do
  @moduledoc false
  
  use ExUnit.Case
  doctest MsLuis

  setup do
    bypass = Bypass.open([port: 8080])

    {:ok, bypass: bypass}
  end

  test "get_intent/1 should send a valid request", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/luis/v2.0/apps/my-app-key"
      assert conn.query_string == "subscription-key=my-sub-key&verbose=true&q=hello%20there%20you"

      conn
      |> Plug.Conn.put_resp_content_type("text/plain")
      |> Plug.Conn.send_resp(200, "")
    end

    {:ok, result} = MsLuis.get_intent("hello there you")

    assert result == ""
  end

  test "get_intent/1 should respond with the decoded LUIS response", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, "{\"topScoringIntent\": \"test\"}")
    end

    {:ok, result} = MsLuis.get_intent("hello")

    assert result == %{"topScoringIntent" => "test"}
  end
end
