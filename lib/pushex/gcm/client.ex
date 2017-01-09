defmodule Pushex.GCM.Client do
  @moduledoc """
  Module defining the behaviour to send requests to GCM.

  The behaviour can be changed by setting the `:client_impl` module
  under the configuration `pushex: :gcm` key
  """

  @callback send_notification(notification :: Pushex.GCM.Request.t) :: {:ok, Pushex.GCM.Response.t} | {:error, Pushex.GCM.HTTPError}

  def send_notification(notification) do
    impl().send_notification(notification)
  end

  defp impl(), do: Application.get_env(:pushex, :gcm)[:client_impl]
end
