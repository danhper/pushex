defmodule Pushex.Config do
  @moduledoc false

  use GenServer

  @default_gcm_endpoint "https://android.googleapis.com/gcm"

  @default_apns_development_endpoint "api.development.push.apple.com"
  @default_apns_production_endpoint "api.push.apple.com"
  @default_apns_protocol :https
  @default_apns_port 443

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    opts |> make_defaults() |> do_configure()
    {:ok, []}
  end

  def event_handlers do
    for handler <- Application.get_env(:pushex, :event_handlers, []) do
      {Pushex.EventManager, handler, []}
    end
  end

  def configure(options) do
    GenServer.call(__MODULE__, {:configure, options})
  end

  def add_event_handler(handler) do
    GenServer.call(__MODULE__, {:add_event_handler, handler})
  end

  def handle_call({:configure, options}, _from, state) do
    do_configure(options)
    {:reply, :ok, state}
  end

  def handle_call({:add_event_handler, handler}, _from, state) do
    update_event_handlers(&[handler|List.delete(&1, handler)])
    {:reply, :ok, state}
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
      |> Keyword.put_new(:pool_options, [size: 100, max_overflow: 20])

    apns_config =
      Keyword.get(config, :apns, [])
      |> Keyword.put_new(:pool_options, [size: 100, max_overflow: 20])
      |> Keyword.put_new(:dev_endpoint, @default_apns_development_endpoint)
      |> Keyword.put_new(:prod_endpoint, @default_apns_production_endpoint)
      |> Keyword.put_new(:port, @default_apns_port)
      |> Keyword.put_new(:protocol, @default_apns_protocol)

    config
    |> Keyword.put(:gcm, gcm_config)
    |> Keyword.put(:apns, apns_config)
    |> load_apps(:gcm, Pushex.GCM.App)
    |> load_apps(:apns, Pushex.APNS.App)
    |> Keyword.put_new(:app_manager_impl, Pushex.AppManager.Memory)
    |> Keyword.put_new(:event_handlers, [])
  end

  defp make_normal_settings(config) do
    gcm_config =
      Keyword.get(config, :gcm, [])
      |> Keyword.put_new(:client_impl, Pushex.GCM.Client.HTTP)
    apns_config = config
      |> Keyword.get(:apns, [])
      |> Keyword.put_new(:client_impl, Pushex.APNS.Client.SSL)
    config
    |> Keyword.put(:gcm, gcm_config)
    |> Keyword.put(:apns, apns_config)
  end

  defp make_sandbox_defaults(config) do
    base_handlers = Keyword.get(config, :event_handlers, [])
    event_handlers = if Enum.find(base_handlers, &(&1 == Pushex.EventHandler.Sandbox)) do
      base_handlers
    else
      base_handlers ++ [Pushex.EventHandler.Sandbox]
    end
    gcm_config =
      Keyword.get(config, :gcm, [])
      |> Keyword.put_new(:client_impl, Pushex.GCM.Client.Sandbox)
    apns_config =
      Keyword.get(config, :apns, [])
      |> Keyword.put_new(:client_impl, Pushex.APNS.Client.Sandbox)

    config
    |> Keyword.put(:gcm, gcm_config)
    |> Keyword.put(:apns, apns_config)
    |> Keyword.put(:event_handlers, event_handlers)
  end

  defp load_apps(config, platform, mod) do
    apps =
      Keyword.get(config[platform], :apps, [])
      |> Enum.map(&mod.create!/1)
      |> Enum.group_by(&(&1.name))
      |> Enum.map(fn {k, v} -> {k, List.first(v)} end)
      |> Enum.into(%{})
    Keyword.put(config, :apps, [{platform, apps} | Keyword.get(config, :apps, [])])
  end

  defp update_event_handlers(fun) do
    event_handlers = fun.(Application.get_env(:pushex, :event_handlers, []))
    Application.put_env(:pushex, :event_handlers, event_handlers)
  end

  defp do_configure(options) do
    Enum.each options, fn {key, value} ->
      Application.put_env(:pushex, key, value)
    end
  end
end
