defmodule MsLuis.Permissions do
  @moduledoc """
    The `MsLuis.Permissions` module is used to manage the `permissions` resource on the Microsoft LUIS API.
  """

  alias MsLuis.ApiRequest

  @doc """
  Adds a user to the access list for the given `app_id`

  Args

    * `app_id` - a binary containing the id for the application
    * `email` - a string containing the email address to add

  Usage

      MsLuis.Permissions.add_user("123", "someone@example.com")
      # :ok
  """
  @spec add_user(binary, binary) :: :ok | {:error, binary | atom}
  def add_user(app_id, email),
    do: ApiRequest.send("permissions", :post, param: app_id, body: %{email: email})

  @doc """
  Returns the a list of users from the access list for the given `app_id`

  Args

    * `app_id` - a binary containing the id for the application

  Usage

      MsLuis.Apps.get_users("123")
      # {:ok, %{"email" => ["someone@example.com"]}
  """
  @spec get_users(binary) :: {:ok, map} | {:error, binary | atom}
  def get_users(app_id), do: ApiRequest.send("permissions", :get, param: app_id)

  @doc """
  NOTE: this function is currently not implemented due to a restriction
        with the http client used

  Deletes a user from the access list for the given `app_id`

  Args

    * `app_id` - a binary containing the id for the application
    * `email` - a string containing the email address to delete

  Usage

      MsLuis.Permissions.delete_user("123", "someone@example.com")
      # :ok
  """
  @spec delete_user(binary, binary) :: :ok | {:error, binary | atom}
  def delete_user(_app_id, _email),
    do: :not_implemented
    #do: ApiRequest.send("permissions", :delete, param: app_id, body: %{email: email})

  @doc """
  Updates the user access list for the given `app_id`

  Args

    * `app_id` - a binary containing the id for the application
    * `emails` - a list containing all the email addresses for the access list

  Usage

      MsLuis.Permissions.update_users("123", ["someone@example.com"])
      # :ok
  """
  @spec update_users(binary, list) :: :ok | {:error, binary | atom}
  def update_users(app_id, emails),
    do: ApiRequest.send("permissions", :put, param: app_id, body: %{emails: emails})
end