defmodule Pushex.GCM.Client do
  @callback send_enotification(notification :: Pushex.GCM.Notification) :: {:ok, Pushex.GCM.Response} | {:error, Pushex.GCM.HTTPError}

  def send_notification(notification) do
    impl.send_notification(notification)
  end

  defp impl, do: Application.get_env(:pushex, :gcm)[:client_impl]
end
