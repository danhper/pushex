defmodule Pushex.Util do
  def validate(data) do
    validate(data, Vex.Extract.settings(data))
  end
  defp validate(data, settings) do
    case Vex.errors(data, settings) do
      errors when errors != [] -> {:error, errors}
      _ -> {:ok, data}
    end
  end

  def normalize_notification(notification, platform) do
    {platform_data, notification} = cond do
      Map.has_key?(notification, platform) ->
        Map.pop(notification, platform)
      Map.has_key?(notification, to_string(platform)) ->
        Map.pop(notification, to_string(platform))
      true ->
        {%{}, notification}
    end
    Map.merge(notification, platform_data)
  end

  def create_struct!(mod, params) do
    case create_struct(mod, params) do
      {:ok, value}  -> value
      {:error, err} -> raise Pushex.ValidationError, errors: err
    end
  end
  def create_struct(mod, %{__struct__: struct_name} = value) when mod == struct_name do
    validate(value)
  end
  def create_struct(mod, params) when is_map(params) do
    create_struct(mod, struct(mod, params))
  end
  def create_struct(mod, params) when is_list(params) do
    create_struct(mod, Enum.into(params, %{}))
  end
end
