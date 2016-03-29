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
  @spec send_notification(Pushex.GCM.Request.t | map, Keyword.t) :: reference
  def send_notification(notification, opts \\ [])
  def send_notification(%Pushex.GCM.Request{} = notification, opts) do
    send_gcm_notification(notification, opts)
  end
  def send_notification(notification, opts) do
    if opts[:using] do
      send_notification(notification, opts[:using], opts)
    else
      case Keyword.get(opts, :with_app) do
        %Pushex.GCM.App{} -> send_gcm_notification(notification, opts)
        _                 -> raise ArgumentError, ":with_app must be a Pushex.GCM.App when :using is not passed"
      end
    end
  end

  defp send_notification(notification, :gcm, opts) do
    send_gcm_notification(notification, opts)
  end
  defp send_notification(_notification, _, _opts) do
    raise ArgumentError, "you must provide either :with_app or :using"
  end

  defdelegate send_gcm_notification(notification, opts),
    to: Pushex.GCM.Helpers,
    as: :send_notification
end
