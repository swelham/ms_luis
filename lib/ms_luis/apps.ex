defmodule MsLuis.Apps do
  @moduledoc """
    The `MsLuis.Apps` module is used to manage the `apps` resource on the Microsoft LUIS API.
  """

  alias Ivar.Headers

  @base_url "https://westus.api.cognitive.microsoft.com"

  @doc """
  """
  @spec add(map) :: {:ok, binary} | {:error, binary | atom}
  def add(params) do
    with config     <- Application.get_env(:ms_luis, :config),
         {:ok, url} <- build_url(config),
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
    with {:ok, url}     <- Keyword.fetch(config, :url)
    do
      {:ok, "#{url || @base_url}/luis/api/v2.0/apps"}
    else
      _ -> {:error, "There is a missing value in the config for :ms_luis"}
    end
  end
end
