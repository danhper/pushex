defmodule Pushex do
  @moduledoc """
  Facade module to access Pushex functionalities.

  See Pushex.Helpers documentation for more information.
  """

  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    app_manager = Application.get_env(:pushex, :app_manager_impl)
    apps = Pushex.Utils.load_apps_from_config
    children = [
      worker(Pushex.GCM.Worker, []),
      worker(app_manager, [apps])
    ]

    opts = [strategy: :one_for_one, name: Pushex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defdelegate send_notification(notification), to: Pushex.Helpers
  defdelegate send_notification(notification, opts), to: Pushex.Helpers
end
