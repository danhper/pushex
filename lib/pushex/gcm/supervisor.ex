defmodule Pushex.GCM.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    gcm_config = Application.get_env(:pushex, :gcm)

    gcm_pool_options = Keyword.merge([
      name: {:local, Pushex.GCM},
      worker_module: Pushex.Worker,
    ], gcm_config[:pool_options])

    children = [
      :poolboy.child_spec(Pushex.GCM, gcm_pool_options, [client: Pushex.GCM.Client])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
