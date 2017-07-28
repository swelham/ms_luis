defmodule MsLuis.ApiRequest do
  @moduledoc false

  @base_url "https://westus.api.cognitive.microsoft.com"

  def send(endpoint), do: send(endpoint, :get, nil)
  def send(endpoint, method, params) do
    with config         <- Application.get_env(:ms_luis, :config),
         {:ok, url}     <- build_url(params, endpoint, config),
         {:ok, opts}    <- build_opts(config, params[:opts]),
         {:ok, sub_key} <- Keyword.fetch(config, :sub_key)
    do
      Ivar.new(method, url, opts)
      |> put_req_query(params[:query])
      |> put_req_body(method, params[:body])
      |> Ivar.put_headers({"ocp-apim-subscription-key", sub_key})
      |> Ivar.send
      |> Ivar.unpack
      |> respond
    else
      err -> err
    end
  end

  defp respond({:error, %{reason: reason}}), do: {:error, reason}
  defp respond({"", _}), do: :ok
  defp respond({content, _}), do: {:ok, content}
  defp respond(resp), do: resp

  defp put_req_query(req, nil), do: req
  defp put_req_query(req, params),
    do: Ivar.put_query_string(req, params)

  defp put_req_body(req, _, nil), do: req
  defp put_req_body(req, method, _) when method in [:get, :delete],
    do: req
  defp put_req_body(req, _, params),
    do: Ivar.put_body(req, params, :json)

  defp append_url_param(url, params) when is_binary(params),
    do: "#{url}/#{params}"
  defp append_url_param(url, _), do: url

  defp build_url(_, _, nil), do: {:error, "No config found for :ms_luis"}
  defp build_url(params, endpoint, config) do
    url = config
    |> Keyword.get(:url, @base_url)
    |> Kernel.<>("/luis/api/v2.0/apps")
    |> append_url_param(params[:param])
    |> append_endpoint(endpoint)

    {:ok, url}
  end

  defp build_opts(nil, _), do: {:error, "No config found for :ms_luis"}
  defp build_opts(config, nil), do: build_opts(config, [])
  defp build_opts(config, opts) do
    opts = config[:ssl_protocol]
    |> build_ssl_protocol_string
    |> Keyword.merge(opts)

    {:ok, opts}
  end

  defp build_ssl_protocol_string(version),
    do: [ssl: [{:versions, [version || :"tlsv1.2"]}]]

  defp append_endpoint(url, ""), do: url
  defp append_endpoint(url, endpoint), do: "#{url}/#{endpoint}"
end