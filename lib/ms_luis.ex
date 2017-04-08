defmodule MsLuis do
  @moduledoc """
  The `MsLuis` module is used to send requests to the LUIS service.
  """

  @doc """

  """
  def get_intent(query) do
    with config     <- Application.get_env(:ms_luis, :config),
         {:ok, url} <- build_url(config, query)
    do
      Ivar.new(:get, url)
      |> Ivar.send
      |> Ivar.unpack
      |> respond
    else
      err -> err
    end
  end

  defp build_url(nil, _), do: {:error, "No config found for :ms_luis"}
  defp build_url(config, query) do
    with {:ok, url}     <- Keyword.fetch(config, :url),
         {:ok, app_key} <- Keyword.fetch(config, :app_key),
         {:ok, sub_key} <- Keyword.fetch(config, :sub_key)
    do
      {:ok, "#{url}/luis/v2.0/apps/#{app_key}?subscription-key=#{sub_key}&verbose=true&q=#{query}"}
    else
      _ -> {:error, "There is a missing value in the config for :ms_luis"}
    end
  end

  defp respond({content, %HTTPoison.Error{reason: reason}}), do: {:error, reason}
  defp respond({content, _}), do: {:ok, content}
  defp respond(resp), do: resp
end
