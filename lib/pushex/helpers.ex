defmodule Pushex.Helpers do
  @moduledoc """
  Module containing helpers functions to use Pushex functionalities easily.
  """

  @doc """
  Sends a notification asynchrnously.
  The first argument can be a notification or a full request (i.e. a `Pushex.GCM.Request`)

  When using the first form, all the options passed will be passed to
  the request (e.g. `:priority`)

  The function raises an exception if the request cannot be executed,
  for example if a parameter is missing, or the requested application is not found.
  If the request is executed but fails, it should be handled in the response handler.

  ## Examples

      notification = %{title: "my title", body: "my body"}

      app    = %Pushex.GCM.App{name: "some name", auth_key: "my_auth_key"}
      reg_id = get_my_registration_id
      Pushex.send_notification(notification, to: reg_id, with_app: app)

      # with default_app setup
      Pushex.send_notification(notification, to: reg_id, using: :gcm)


      request = %Pushex.GCM.Request{app: app, notification: notification, to: reg_id}
      Pushex.send_notification(request)
  """
  @spec send_notification(Pushex.GCM.request | Pushex.APNS.request | map, Keyword.t) :: reference
  def send_notification(request, opts \\ [])
  def send_notification(%Pushex.GCM.Request{} = request, _opts) do
    Pushex.Worker.send_notification(request)
  end
  def send_notification(%Pushex.APNS.Request{} = request, _opts) do
    Pushex.Worker.send_notification(request)
  end
  def send_notification(notification, opts) do
    if opts[:using] do
      do_send_notification(notification, opts[:using], opts)
    else
      case Keyword.get(opts, :with_app) do
        %Pushex.GCM.App{}  -> do_send_notification(notification, :gcm, opts)
        %Pushex.APNS.App{} -> do_send_notification(notification, :apns, opts)
        _                  -> raise ArgumentError, ":with_app must be a `Pushex.GCM.App` or `Pushex.APNS.App` when :using is not passed"
      end
    end
  end

  defp do_send_notification(notification, platform, opts) when platform in ["gcm", "apns"] do
    do_send_notification(notification, String.to_atom(platform), opts)
  end
  defp do_send_notification(notification, platform, opts) when platform in [:gcm, :apns] do
    {app, opts} = Keyword.pop(opts, :with_app)
    app = fetch_app(platform, app || default_app(platform))
    request = make_request(notification, app, opts)
    Pushex.Worker.send_notification(request)
  end
  defp do_send_notification(_notification, platform, _opts) do
    raise ArgumentError, "#{inspect(platform)} is not a valid platform"
  end

  defp fetch_app(platform, nil) do
    raise ArgumentError, """
    you need to define a default app for the #{platform} in your config
    or to pass one explicitly with the :with_app parameter
    """
  end
  defp fetch_app(_platform, %Pushex.GCM.App{} = app), do: app
  defp fetch_app(_platform, %Pushex.APNS.App{} = app), do: app
  defp fetch_app(platform, app_name) when is_binary(app_name) or is_atom(app_name) do
    case Pushex.AppManager.find_app(platform, app_name) do
      nil -> raise Pushex.AppNotFoundError, platform: platform, name: app_name
      app -> app
    end
  end

  defp make_request(notification, %Pushex.GCM.App{} = app, opts) do
    Pushex.GCM.Request.create!(notification, app, opts)
  end
  defp make_request(notification, %Pushex.APNS.App{} = app, opts) do
    Pushex.APNS.Request.create!(notification, app, opts)
  end
  defp make_request(_notification, app, _opts) do
    raise ArgumentError, "application must be Pushex.GCM.App or Pushex.APNS.app, got #{inspect(app)}"
  end

  defp default_app(platform) do
    Application.get_env(:pushex, platform)[:default_app]
  end
end
