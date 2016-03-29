defmodule Pushex.GCM.Helpers do
  @default_app Application.get_env(:pushex, :gcm)[:default_app]

  @doc """
  Sends a notification to GCM asynchrnously.
  """
  @spec send_notification(Pushex.GCM.Request.t | map, Keyword.t) :: reference
  def send_notification(request, opts \\ [])

  def send_notification(%Pushex.GCM.Request{} = request, _opts) do
    Pushex.GCM.Worker.send_notification(request)
  end

  def send_notification(notification, opts) do
    {app, opts} = Keyword.pop(opts, :with_app)
    app = fetch_app(app || @default_app)
    do_send_notification(notification, app, opts)
  end

  defp do_send_notification(notification, app, opts) do
    opts
    |> Keyword.put(:notification, notification)
    |> Keyword.put(:app, app)
    |> normalize_opts
    |> Pushex.GCM.Request.create!
    |> send_notification(notification)
  end

  defp fetch_app(%Pushex.GCM.App{} = app), do: app
  defp fetch_app(app_name) when is_binary(app_name) do
    case Pushex.AppManager.find_app(:gcm, app_name) do
      nil -> raise Pushex.AppNotFoundError, platform: :gcm, name: app_name
      app -> app
    end
  end
  defp fetch_app(nil) do
    raise ArgumentError, "you need to define a default app for GCM in your config or \
    to pass one explicitly with the :with_app parameter"
  end

  defp normalize_opts(opts) do
    if is_list(opts[:to]) do
      {to, opts} = Keyword.pop(opts, :to)
      Keyword.put(opts, :registration_ids, to)
    else
      opts
    end
  end
end
