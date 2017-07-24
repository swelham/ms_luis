defmodule MsLuis.Apps do
  @moduledoc """
    The `MsLuis.Apps` module is used to manage the `apps` resource on the Microsoft LUIS API.
  """

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
  def add(params), do: send_request("", :post, body: params)

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
    params = replace_key(params, :domain_name, :domainName)
    
    send_request("customprebuiltdomains", :post, body: params)
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
  def delete(app_id), do: send_request("", :delete, param: app_id)

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

    send_request("queryLogs", :get, param: app_id)
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
  def get_info(app_id), do: send_request("", :get, param: app_id)

  @doc """
  Returns the application settings for the given `app_id`

  Args

    * `app_id` - a binary containing the id for the application

  Usage

      MsLuis.Apps.get_settings("123")
      # {:ok, %{"id" => "123", "public" => true}}
  """
  @spec get_settings(binary) :: {:ok, map} | {:error, binary | atom}
  def get_settings(app_id), do: send_request("settings", :get, param: app_id)

  @doc """
  Returns a list of usage scenarios

  Usage

      MsLuis.Apps.get_usage_scenarios()
      # {:ok, ["IoT", "Bot", ...}]}
  """
  @spec get_usage_scenarios() :: {:ok, list} | {:error, binary | atom}
  def get_usage_scenarios(), do: send_request("usagescenarios")

  @doc """
  Returns a list of custom prebuilt domains

  Usage

      MsLuis.Apps.get_prebuilt_domains()
      # {:ok, [%{"name" => "weather", ...}]}
  """
  @spec get_prebuilt_domains() :: {:ok, list} | {:error, binary | atom}
  def get_prebuilt_domains(), do: send_request("customprebuiltdomains")

  @doc """
  Returns a list of custom prebuilt domains for the given `culture`

  Args

    * `culture` - a binary containing a valid culture code (e.g. `en-us`)

  Usage

      MsLuis.Apps.get_prebuilt_domains("en-us")
      # {:ok, [%{"name" => "weather", ...}]}
  """
  @spec get_prebuilt_domains(binary) :: {:ok, list} | {:error, binary | atom}
  def get_prebuilt_domains(culture),
    do: send_request("customprebuiltdomains/#{culture}")

  @doc """
  Returns the endpoint URLs of the personal assistant applications

  Usage

      MsLuis.Apps.get_assistants()
      # {:ok, %{"endpointKeys" => [],"endpointUrls" => %{...}}}
  """
  @spec get_assistants() :: {:ok, map} | {:error, binary | atom}
  def get_assistants(), do: send_request("assistants")

  @doc """
  Returns a list of the users applications

  Usage

      MsLuis.Apps.get()
      # {:ok, [%{"id" => "4754ab84-7590-4bbe-a723-38151a7fee09", ...}]
  """
  @spec get() :: {:ok, list} | {:error, binary | atom}
  def get(), do: send_request("")

  @doc """
  Returns a list of the users applications limited by the `skip`/`take` params

  Args

    * `params` - a map that may contain the `skip` and `take` keys with a numeric value

  Usage

      MsLuis.Apps.get(%{skip: 10, take: 5})
      # {:ok, [%{"id" => "4754ab84-7590-4bbe-a723-38151a7fee09", ...}]
  """
  @spec get(map) :: {:ok, list} | {:error, binary | atom}
  def get(params), do: send_request("", :get, query: params)

  @doc """
  Imports an existing application

  Args

    * `params` - a map that contains the valid application structure

  Usage

      MsLuis.Apps.import(%{name: "test_app", ...})
      # {:ok, "4754ab84-7590-4bbe-a723-38151a7fee09"}
  """
  @spec import(map) :: {:ok, binary} | {:error, binary | atom}
  def import(params), do: send_request("import", :post, body: params)

  @doc """
  Imports an existing application

  Args

    * `params` - a map that contains the valid application structure
    * `app_name` - a binary used to specify the imported application name

  Usage

      MsLuis.Apps.import(%{name: "test_app", ...}, "my_test_app")
      # {:ok, "4754ab84-7590-4bbe-a723-38151a7fee09"}
  """
  @spec import(map, binary) :: {:ok, binary} | {:error, binary | atom}
  def import(params, app_name),
    do: send_request("import", :post, body: params, query: %{appName: app_name})

  @doc """
  Send a request to publish an application for the given `app_id`

  Args

    * `app_id` - a binary contianing the application id to be published
    * `params` - a map that contains the valid publish application request structure

  Usage

      MsLuis.Apps.publish("4754ab84-7590-4bbe-a723-38151a7fee09", %{versionId: "0.1"})
      # {:ok, %{"endpointUrl" => "TestURL", ...}}
  """
  @spec import(binary, map) :: {:ok, map} | {:error, binary | atom}
  def publish(app_id, params),
    do: send_request("publish", :post, param: app_id, body: params)

  @doc """
  Renames the application for the given `app_id`

  Args

    * `app_id` - a binary contianing the application id to be published
    * `params` - a map that contains the valid rename application request structure

  Usage

      MsLuis.Apps.rename("4754ab84-7590-4bbe-a723-38151a7fee09", %{name: "my_new_name"})
      # :ok
  """
  @spec rename(binary, map) :: {:ok, map} | {:error, binary | atom}
  def rename(app_id, params),
    do: send_request("", :put, param: app_id, body: params)

  @doc """
  Updates the application settings for the given `app_id`

  Args

    * `app_id` - a binary contianing the application id to be published
    * `params` - a map that contains the valid application settings udpate request structure

  Usage

      MsLuis.Apps.update_settigns("4754ab84-7590-4bbe-a723-38151a7fee09", %{public: true})
      # :ok
  """
  @spec update_settings(binary, map) :: {:ok, map} | {:error, binary | atom}
  def update_settings(app_id, params),
    do: send_request("settings", :put, param: app_id, body: params)

  defp replace_key(map, from, to) do
    value = Map.get(map, from)

    map
    |> Map.put(to, value)
    |> Map.drop([from])
  end

  defp transform_query_logs({:ok, _}, output) when not output in [:raw, :parsed],
    do: {:error, "':#{output}' is not a valid output type"}
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

  defp send_request(endpoint), do: send_request(endpoint, :get, nil)
  defp send_request(endpoint, method, params) do
    with config         <- Application.get_env(:ms_luis, :config),
         {:ok, url}     <- build_url(params, endpoint, config),
         {:ok, sub_key} <- Keyword.fetch(config, :sub_key)
    do
      Ivar.new(method, url)
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

  defp respond({_, %HTTPoison.Error{reason: reason}}), do: {:error, reason}
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
    url = case Keyword.fetch(config, :url) do
      {:ok, cfg_url} -> cfg_url
      _ -> @base_url
    end
    |> Kernel.<>("/luis/api/v2.0/apps")
    |> append_url_param(params[:param])
    |> append_endpoint(endpoint)

    {:ok, url}
  end

  defp append_endpoint(url, ""), do: url
  defp append_endpoint(url, endpoint), do: "#{url}/#{endpoint}"
end
