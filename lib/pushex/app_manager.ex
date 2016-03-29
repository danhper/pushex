defmodule Pushex.AppManager do
  @callback find_app(platform :: atom, name :: String.t) :: Pushex.GCM.App

  def find_app(platform, name) do
    impl.find_app(platform, name)
  end

  defp impl, do: Application.get_env(:pushex, :app_manager_impl)
end
