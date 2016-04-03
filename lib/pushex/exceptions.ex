defmodule Pushex.ValidationError do
  @moduledoc """
  `Pushex.ValidationError` is raised when a request contains invalid or incomplete data
  """
  defexception [:errors]

  def message(err) do
    List.wrap(err.errors)
    |> Enum.map(&format_error/1)
    |> Enum.join(". ")
  end

  defp format_error({:error, field, validator, error}) do
    "error on #{inspect(field)} with #{inspect(validator)} validator: #{error}"
  end
end

defmodule Pushex.AppNotFoundError do
  @moduledoc """
  `Pushex.AppNotFoundError` is raised when the app to send the request do not exist.
  """

  defexception [:platform, :name]

  def message(err) do
    "could not find an app named #{inspect(err.name)} for platform #{inspect(err.platform)}"
  end
end
