defmodule MsLuis.Apps do
  @moduledoc """
    The `MsLuis.Apps` module is used to manage the `apps` resource on the Microsoft LUIS API.
  """

  alias Ivar.Headers

  @base_url "https://westus.api.cognitive.microsoft.com"

  @doc """
  Sends a request to create an new application and returns the ID for the newly created application

  Args

    * `params` - a map that represents the data required for the add application endpoint

  Usage

      MsLuis.Apps.add(%{name: "My App", culture: "en-us"})
      # {:ok, "<GUID>"}
  """
  @spec add(map) :: {:ok, binary} | {:error, binary | atom}
  def add(params) do
    with config         <- Application.get_env(:ms_luis, :config),
         {:ok, url}     <- build_url(config),
         {:ok, sub_key} <- Keyword.fetch(config, :sub_key)
    do
      Ivar.new(:post, url)
      |> Ivar.put_body(params, :json)
      |> Headers.put("ocp-apim-subscription-key", sub_key)
      |> Ivar.send
      |> Ivar.unpack
      |> respond
    else
      err -> err
    end
  end

  defp respond({_, %HTTPoison.Error{reason: reason}}), do: {:error, reason}
  defp respond({content, _}), do: {:ok, content}
  defp respond(resp), do: resp

  defp build_url(nil), do: {:error, "No config found for :ms_luis"}
  defp build_url(config) do
    url = case Keyword.fetch(config, :url) do
      {:ok, cfg_url} -> cfg_url
      _ -> @base_url
    end

    {:ok, "#{url}/luis/api/v2.0/apps"}
  end
end
