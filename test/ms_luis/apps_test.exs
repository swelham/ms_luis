defmodule MsLuisTest.Apps do
  use ExUnit.Case
  doctest MsLuis

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
      assert body == "{\"name\":\"test app\"}"

      conn
      |> Plug.Conn.put_resp_content_type("text/plain")
      |> Plug.Conn.send_resp(201, "123")
    end

    {:ok, id} = Apps.add(%{name: "test app"})

    assert id == "123"
  end
end