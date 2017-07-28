defmodule MsLuis.Examples do
  @moduledoc """
    The `MsLuis.Examples` module is used to manage the `examples` resource on the Microsoft LUIS API.
  """

  alias MsLuis.ApiRequest

  @doc """
  Adds a new label for the given `app_id` and `version_id`

  Args

    * `app_id` - a binary containing the id for the application
    * `version_id` - a binary containing the id for the version
    * `params` - a map that represents the data required for the add label endpoint

  Usage

      MsLuis.Examples.add_label("123", "0.1", %{text: "book me a flight", ...})
      # {:ok, [%{"ExampleId" => -11, ...}]}
  """
  @spec add_label(binary, binary, map) :: {:ok, map} | {:error, binary | atom}
  def add_label(app_id, version_id, params),
    do: ApiRequest.send("versions/#{version_id}/example", :post, param: app_id, body: params)

  @doc """
  Adds a batch of new labels for the given `app_id` and `version_id`

  Args

    * `app_id` - a binary containing the id for the application
    * `version_id` - a binary containing the id for the version
    * `params` - a map that represents the data required for the add batch labels endpoint

  Usage

      MsLuis.Examples.add_labels("123", "0.1", [%{text: "book me a flight", ...}])
      # {:ok, [%{"ExampleId" => -11, ...}]}
  """
  @spec add_labels(binary, binary, map) :: {:ok, map} | {:error, binary | atom}
  def add_labels(app_id, version_id, params),
    do: ApiRequest.send("versions/#{version_id}/examples", :post, param: app_id, body: params)

  @doc """
  Deletes a label specified by the `example_id` for the given `app_id` and `version_id`

  Args

    * `app_id` - a binary containing the id for the application
    * `version_id` - a binary containing the id for the version
    * `example_id` - a binary containing the id for the example

  Usage

      MsLuis.Examples.delete_label("123", "0.1", "-11")
      # :ok
  """
  @spec delete_label(binary, binary, binary) :: :ok | {:error, binary | atom}
  def delete_label(app_id, version_id, example_id),
    do: ApiRequest.send("versions/#{version_id}/examples/#{example_id}", :delete, param: app_id)

  @doc """
  Returns a list of labels to be reviewed for the given `app_id` and `version_id`

  Args

    * `app_id` - a binary containing the id for the application
    * `version_id` - a binary containing the id for the version

  Usage

      MsLuis.Examples.get_labels_to_review("123", "0.1")
      # :{ok, [%{"id" => -11, ...}]
  """
  @spec get_labels_to_review(binary, binary) :: {:ok, list} | {:error, binary | atom}
  def get_labels_to_review(app_id, version_id),
    do: ApiRequest.send("versions/#{version_id}/examples", :get, param: app_id)

  @doc """
  Returns a list of labels to be reviewed for the given `app_id` and `version_id`

  Args

    * `app_id` - a binary containing the id for the application
    * `version_id` - a binary containing the id for the version
    * `params` - a map that may contain the `skip` and `take` keys with a numeric value

  Usage

      MsLuis.Examples.get_labels_to_review("123", "0.1", %{skip: 10, take: 5})
      # :{ok, [%{"id" => -11, ...}]
  """
  @spec get_labels_to_review(binary, binary, map) :: {:ok, list} | {:error, binary | atom}
  def get_labels_to_review(app_id, version_id, params),
    do: ApiRequest.send("versions/#{version_id}/examples", :get, param: app_id, query: params)
end