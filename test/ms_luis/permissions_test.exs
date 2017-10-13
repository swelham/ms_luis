defmodule MsLuisTest.Permissions do
  @moduledoc false
  
  use ExUnit.Case
  doctest MsLuis.Permissions

  import MsLuisTest.TestMacros

  alias MsLuis.Permissions

  setup do
    bypass = Bypass.open([port: 8080])

    {:ok, bypass: bypass}
  end

  test "add_user/2 should send a valid add user to access list request", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert conn.method == "POST"
      assert conn.request_path == "/luis/api/v2.0/apps/123/permissions"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})
      assert body == "{\"email\":\"someone@example.com\"}"

      Plug.Conn.send_resp(conn, 200, "")
    end

    assert :ok == Permissions.add_user("123", "someone@example.com")
  end

  test "get_users/1 should return a list of users who are in the access list", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/luis/api/v2.0/apps/123/permissions"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, "{\"emails\":[\"someone@example.com\"]}")
    end

    {:ok, result} = Permissions.get_users("123")

    assert result == %{"emails" => ["someone@example.com"]}
  end

  # doesn't look like hackney supports delete requests with a body, need to change http client
  # and add support for this endpoint
  @tag skip: true
  test "delete_user/2 should send a valid delete user from access list request", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)
      
      assert conn.method == "DELETE"
      assert conn.request_path == "/luis/api/v2.0/apps/123/permissions"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})
      assert body == "{\"email\":\"someone@example.com\"}"

      Plug.Conn.send_resp(conn, 200, "")
    end

    assert :ok == Permissions.delete_user("123", "someone@example.com")
  end

  test "update_users/2 should send a valid update user access list request", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert conn.method == "PUT"
      assert conn.request_path == "/luis/api/v2.0/apps/123/permissions"
      assert has_header(conn, {"ocp-apim-subscription-key", "my-sub-key"})
      assert body == "{\"emails\":[\"someone@example.com\"]}"

      Plug.Conn.send_resp(conn, 200, "")
    end

    assert :ok == Permissions.update_users("123", ["someone@example.com"])
  end
end