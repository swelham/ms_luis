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
      # {:ok, "4754ab84-7590-4bbe-a723-38151a7fee09"}
  """
  @spec add(map) :: {:ok, binary} | {:error, binary | atom}
  def add(params), do: send_request(params, :post)

  @doc """
  Sends a request to create an new prebuilt application and returns the ID for the newly created application

  Args

    * `params` - a map that represents the data required for the add prebuilt application endpoint

  Usage

      MsLuis.Apps.add_prebuilt(%{domain_name: "Web", culture: "en-us"})
      # {:ok, "4754ab84-7590-4bbe-a723-38151a7fee09"}
  """
  @spec add_prebuilt(map) :: {:ok, binary} | {:error, binary | atom}
  def add_prebuilt(params) do
    params
    |> replace_key(:domain_name, :domainName)
    |> send_request(:post, "customprebuiltdomains")
  end

  @doc """
  Sends a request to delete an the application specified by the `app_id`

  Args

    * `app_id` - a binary containing the id for the application to be deleted

  Usage

      MsLuis.Apps.delete("4754ab84-7590-4bbe-a723-38151a7fee09")
      # :ok
  """
  @spec delete(binary) :: :ok | {:error, binary | atom}
  def delete(app_id), do: send_request(app_id, :delete)

  @doc """
  Returns the application query logs for the given `app_id`

  Args

    * `app_id` - a binary containing the id for the application to be deleted
    * `opts` - a keyword list of options

  Options

    * `:output` - determines the output format of the result, available values are `:raw | :parsed`. Default is: `:parsed`

  Usage

      MsLuis.Apps.get_query_logs("4754ab84-7590-4bbe-a723-38151a7fee09")
      # {:ok, [%{ query: "turn the lights off", datetime: "07/19/2017 12:55:20", response: %{...}}]}
  """
  @spec get_query_logs(binary, Keyword.t) :: {:ok, map | binary} | {:error, binary | atom}
  def get_query_logs(app_id, opts \\ []) do
    output = Keyword.get(opts, :output, :parsed)

    send_request(app_id, :get, "queryLogs")
    |> transform_query_logs(output)
  end

  @doc """
  Returns a list of available cultures

  Usage

      MsLuis.Apps.get_cultures()
      # {:ok, [%{"code" => "en-us", "name" => "English"}, ...}]}
  """
  @spec get_cultures() :: {:ok, list} | {:error, binary | atom}
  def get_cultures(), do: send_request("cultures")

  @doc """
  Returns a list of available domains

  Usage

      MsLuis.Apps.get_domains()
      # {:ok, ["Business", "Communication", ...}]}
  """
  @spec get_domains() :: {:ok, list} | {:error, binary | atom}
  def get_domains(), do: send_request("domains")

  @doc """
  Returns the application info for the given `app_id`

  Args

    * `app_id` - a binary containing the id for the application

  Usage

      MsLuis.Apps.get_info("123")
      # {:ok, %{"id" => "123", "name" => "test_app", ...}}
  """
  @spec get_info(binary) :: {:ok, map} | {:error, binary | atom}
  def get_info(app_id), do: send_request(app_id, :get)

  @doc """
  Returns the application settings for the given `app_id`

  Args

    * `app_id` - a binary containing the id for the application

  Usage

      MsLuis.Apps.get_settings("123")
      # {:ok, %{"id" => "123", "public" => true}}
  """
  @spec get_settings(binary) :: {:ok, map} | {:error, binary | atom}
  def get_settings(app_id), do: send_request(app_id, :get, "settings")

  @doc """
  Returns a list of usage scenarios

  Usage

      MsLuis.Apps.get_usage_scenarios()
      # {:ok, ["IoT", "Bot", ...}]}
  """
  @spec get_usage_scenarios() :: {:ok, list} | {:error, binary | atom}
  def get_usage_scenarios(), do: send_request("usagescenarios")

  defp replace_key(map, from, to) do
    value = Map.get(map, from)

    map
    |> Map.put(to, value)
    |> Map.drop([from])
  end

  defp transform_query_logs({:ok, _}, output) when not output in [:raw, :parsed], do:
    {:error, "':#{output}' is not a valid output type"}
  defp transform_query_logs({:ok, logs}, :parsed) do
    logs = logs
    |> String.split("\n")
    |> Enum.drop(1)
    |> Enum.map(&map_log_item/1)
    |> Enum.filter(& &1 != nil)

    {:ok, logs}
  end
  defp transform_query_logs(logs, _), do: logs

  defp map_log_item(""), do: nil
  defp map_log_item(log) do
    [query, datetime, response] = log
    |> String.replace("\r", "")
    |> String.replace("\"\"", "\"")
    |> String.split(",", parts: 3)

    response = String.replace(response, ~r/"({)|(})"/, "\\1\\2")

    %{
      query: String.replace(query, "\"", ""),
      datetime: datetime,
      response: Poison.decode!(response)
    }
  end

  defp send_request(endpoint), do: send_request(nil, :get, endpoint)
  defp send_request(params, method), do: send_request(params, method, "")
  defp send_request(params, method, endpoint) do
    with config         <- Application.get_env(:ms_luis, :config),
         {:ok, url}     <- build_url(params, endpoint, config),
         {:ok, sub_key} <- Keyword.fetch(config, :sub_key)
    do
      Ivar.new(method, url)
      |> put_req_body(method, params)
      |> Headers.put("ocp-apim-subscription-key", sub_key)
      |> Ivar.send
      |> Ivar.unpack
      |> respond
    else
      err -> err
    end
  end

  defp respond({_, %HTTPoison.Error{reason: reason}}), do: {:error, reason}
  defp respond({"", _}), do: :ok
  defp respond({content, _}), do: {:ok, content}
  defp respond(resp), do: resp

  defp put_req_body(req, method, _) when method in [:get, :delete],
    do: req
  defp put_req_body(req, _, params),
    do: Ivar.put_body(req, params, :json)

  defp build_url_query(url, params) when is_binary(params), do: "#{url}/#{params}"
  defp build_url_query(url, _), do: url

  defp build_url(_, _, nil), do: {:error, "No config found for :ms_luis"}
  defp build_url(params, endpoint, config) do
    url = case Keyword.fetch(config, :url) do
      {:ok, cfg_url} -> cfg_url
      _ -> @base_url
    end
    |> Kernel.<>("/luis/api/v2.0/apps")
    |> build_url_query(params)
    |> append_endpoint(endpoint)

    {:ok, url}
  end

  defp append_endpoint(url, ""), do: url
  defp append_endpoint(url, endpoint), do: "#{url}/#{endpoint}"
end
