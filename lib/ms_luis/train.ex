defmodule MsLuis.Train do
  @moduledoc """
    The `MsLuis.Train` module is used to manage the `train` resource on the Microsoft LUIS API.
  """

  alias MsLuis.ApiRequest

  @doc """
  Returns the training status for the given `app_id` and `version_id`

  Args

    * `app_id` - a binary containing the id for the application
    * `version_id` - a binary containing the id for the version

  Usage

      MsLuis.Train.get_status("123", "0.1")
      # {:ok, [%{"modelId" => "4754ab84-7590-4bbe-a723-38151a7fee09", ...}]}
  """
  @spec get_status(binary, binary) :: {:ok, list} | {:error, binary | atom}
  def get_status(app_id, version_id),
    do: ApiRequest.send("versions/#{version_id}/train", :get, param: app_id)
  
  @doc """
  Sends a request to start training the application version specified by the `app_id` and 
  `version_id` parameters

  Args

    * `app_id` - a binary containing the id for the application
    * `version_id` - a binary containing the id for the version

  Usage

      MsLuis.Train.train_version("123", "0.1")
      # {:ok, [%{"modelId" => "4754ab84-7590-4bbe-a723-38151a7fee09", ...}]}
  """
  @spec train_version(binary, binary) :: {:ok, list} | {:error, binary | atom}
  def train_version(app_id, version_id),
    do: ApiRequest.send("versions/#{version_id}/train", :post, param: app_id)
end