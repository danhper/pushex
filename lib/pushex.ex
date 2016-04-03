defmodule Pushex do
  @moduledoc """
  Facade module to access Pushex functionalities.

  See Pushex.Helpers documentation for more information.
  """

  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Pushex.Config.make_defaults

    config = Application.get_all_env(:pushex)

    app_manager = config[:app_manager_impl]
    apps = Pushex.Utils.load_apps_from_config

    children = [
      worker(Pushex.GCM.Worker, [])
    ] ++ supervise_if_startable(app_manager, [apps], &worker/2)

    children = children ++ (if config[:sandbox] do
      [worker(Pushex.Sandbox, [])]
    else
      []
    end)

    opts = [strategy: :one_for_one, name: Pushex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp supervise_if_startable(mod, args, f) do
    Code.ensure_loaded(mod)
    if function_exported?(mod, :start_link, length(args)) do
      [f.(mod, args)]
    else
      []
    end
  end

  defdelegate send_notification(notification), to: Pushex.Helpers
  defdelegate send_notification(notification, opts), to: Pushex.Helpers
end
