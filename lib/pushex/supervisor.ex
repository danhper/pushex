defmodule Pushex.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    config = Pushex.Config.make_defaults(Application.get_all_env(:pushex))

    children = [
      worker(Pushex.Config, [config]),
      worker(:gen_event, [{:local, Pushex.EventManager}]),
      supervisor(Pushex.Watcher, [Pushex.Config, :event_handlers, []]),
      supervisor(Pushex.APNS.Supervisor, []),
      supervisor(Pushex.GCM.Supervisor, []),
      worker(Pushex.AppManager.Memory, []),
    ] ++ sandbox_children(config[:sandbox])

    opts = [strategy: :one_for_one, name: Pushex.Supervisor]
    supervise(children, opts)
  end

  defp sandbox_children(true), do: [worker(Pushex.Sandbox, [])]
  defp sandbox_children(_), do: []
end
