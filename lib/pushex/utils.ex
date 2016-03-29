defmodule Pushex.Utils do
  @moduledoc false

  @doc """
  Loads the application defined in the configuration file.
  """
  @spec load_apps_from_config :: [{:gcm, [Pushex.GCM.App]}]
  def load_apps_from_config do
    [
      gcm: load_gcm_apps
    ]
  end

  defp load_gcm_apps do
    Keyword.get(Application.get_env(:pushex, :gcm), :apps, [])
    |> Enum.map(fn app ->
      app = struct(Pushex.GCM.App, app)
      case Vex.validate(app) do
        {:ok, app} -> {app.name, app}
        {:error, errors} -> raise Pushex.ValidationError, errors: errors
      end
    end)
    |> Enum.into(%{})
  end
end
