defmodule Pushex.AppManager do
  @moduledoc """
  `Pushex.AppManager` is used to retreive applications from their name.

  By default, applications will be loaded from the configuration,
  but this behaviour can be implemented to get an app from a database for example.

  ## Example

      defmodule MyAppManager do
        @behaviour Pushex.AppManager

        def find_app(:gcm, name) do
          app = Repo.find_by(platform: gcm, name: name)
          %Pushex.GCM.App{name: name, auth_key: app.auth_key}
        end
      end
  """

  @callback find_all(platform :: atom) :: [Pushex.GCM.App]
  @callback find_app(platform :: atom, name :: String.t) :: Pushex.GCM.App

  def find_all(platform) do
    impl.find_all(platform)
  end

  def find_app(platform, name) do
    impl.find_app(platform, name)
  end

  defp impl, do: Application.get_env(:pushex, :app_manager_impl)
end
