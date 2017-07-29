defmodule MsLuisTest.TestMacros do
  @moduledoc false
  
  defmacro has_header(conn, header) do
    quote do
      Enum.member?(unquote(conn).req_headers, unquote(header))
    end
  end
end