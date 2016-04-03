defmodule Pushex.Config do
  @moduledoc false

  @default_gcm_endpoint "https://android.googleapis.com/gcm"

  def make_defaults do
    config = Application.get_all_env(:pushex) |> make_common_config()
    config = if config[:sandbox] do
      make_sandbox_defaults(config)
    else
      make_normal_settings(config)
    end
    Enum.each(config, fn {k, v} -> Application.put_env(:pushex, k, v) end)
  end

  defp make_common_config(config) do
    gcm_config =
      Keyword.get(config, :gcm, [])
      |> Keyword.put_new(:endpoint, @default_gcm_endpoint)

    config
    |> Keyword.put(:gcm, gcm_config)
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
end
