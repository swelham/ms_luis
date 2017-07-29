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
end