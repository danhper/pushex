defmodule Pushex.Config do
  @moduledoc false

  use GenServer

  @default_gcm_endpoint "https://android.googleapis.com/gcm"

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  def init(config) do
    {:ok, make_defaults(config)}
  end

  def get(key, default \\ nil) do
    GenServer.call(__MODULE__, {:get, key, default})
  end

  def get_all do
    GenServer.call(__MODULE__, :get_all)
  end

  def set(key, value) do
    GenServer.call(__MODULE__, {:set, key, value})
  end

  def handle_call({:get, key, default}, _from, config) do
    {:reply, Keyword.get(config, key, default), config}
  end

  def handle_call(:get_all, _from, config) do
    {:reply, config, config}
  end

  def handle_call({:set, key, value}, _from, config) do
    {:reply, :ok, Keyword.put(config, key, value)}
  end

  def make_defaults(base_config) do
    config = base_config |> make_common_config()
    if config[:sandbox] do
      make_sandbox_defaults(config)
    else
      make_normal_settings(config)
    end
  end

  defp make_common_config(config) do
    gcm_config =
      Keyword.get(config, :gcm, [])
      |> Keyword.put_new(:endpoint, @default_gcm_endpoint)

    config
    |> Keyword.put(:gcm, gcm_config)
    |> load_gcm_apps()
    |> Keyword.put_new(:app_manager_impl, Pushex.AppManager.Memory)
    |> Keyword.put_new(:response_handlers, [])
  end

  defp make_normal_settings(config) do
    gcm_config =
      Keyword.get(config, :gcm, [])
      |> Keyword.put_new(:client_impl, Pushex.GCM.Client.HTTP)
    config |> Keyword.put(:gcm, gcm_config)
  end

  defp make_sandbox_defaults(config) do
    base_handlers = Keyword.get(config, :response_handlers, [])
    response_handlers = if Enum.find(base_handlers, &(&1 == Pushex.ResponseHandler.Sandbox)) do
      base_handlers
    else
      base_handlers ++ [Pushex.ResponseHandler.Sandbox]
    end
    gcm_config =
      Keyword.get(config, :gcm, [])
      |> Keyword.put_new(:client_impl, Pushex.GCM.Client.Sandbox)

    config
    |> Keyword.put(:gcm, gcm_config)
    |> Keyword.put(:response_handlers, response_handlers)
  end

  defp load_gcm_apps(config) do
    gcm_apps =
      Keyword.get(config[:gcm], :apps, [])
      |> Enum.map(&Pushex.GCM.App.create!/1)
      |> Enum.group_by(&(&1.name))
      |> Enum.map(fn {k, v} -> {k, List.first(v)} end)
      |> Enum.into(%{})
    Keyword.put(config, :apps, [gcm: gcm_apps])
  end
end
