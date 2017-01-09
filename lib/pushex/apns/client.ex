defmodule Pushex.APNS.Client do
  @moduledoc """
  Module defining the behaviour to send requests to APNS..

  The behaviour can be changed by setting the `:client_impl` module
  under the configuration `pushex: :apns` key
  """

  @callback send_notification(request :: APNS.Request.t) :: :ok

  def send_notification(request) do
    impl().send_notification(request)
  end

  defp impl(), do: Application.get_env(:pushex, :apns)[:client_impl]
end
