defmodule Pushex.Util do
  def validate(data) do
    validate(data, Vex.Extract.settings(data))
  end
  def validate(data, settings) do
    case Vex.errors(data, settings) do
      errors when length(errors) > 0 -> {:error, errors}
      _ -> {:ok, data}
    end
  end
end
