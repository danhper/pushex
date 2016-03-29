defmodule Pushex.ValidationError do
  defexception [:errors]

  def message(err) do
    List.wrap(err.errors)
    |> Enum.map(&format_error/1)
    |> Enum.join(". ")
  end

  defp format_error({:error, field, validator, error}) do
    "error on :#{field} with :#{validator} validator: #{error}"
  end
end

defmodule Pushex.AppNotFoundError do
  defexception [:platform, :name]

  def message(err) do
    "could not find an app named #{inspect(err.name)} for platform #{inspect(err.platform)}"
  end
end
