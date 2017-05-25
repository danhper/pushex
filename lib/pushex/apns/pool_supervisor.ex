defmodule Pushex.APNS.PoolSupervisor do
  use Supervisor

  @base_pool_name "apns_pool"

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    supervise([], strategy: :one_for_one)
  end

  def ensure_pool_started(app) do
    pool_name = get_pool_name(app)
    case Process.whereis(pool_name) do
      nil -> Supervisor.start_child(__MODULE__, make_spec(app, pool_name))
      pid -> {:ok, pid}
    end
  end

  defp make_spec(app, pool_name) do
    pool_options = [name: {:local, pool_name}, worker_module: Pushex.APNS.Worker]
    :poolboy.child_spec(pool_name, pool_options, app)
  end

  def get_pool_name(%Pushex.APNS.App{name: name}) do
    String.to_atom("#{@base_pool_name}:#{name}")
  end
end
