defmodule Pushex.GCM.HTTPError do
  defexception [:status_code, :reason]

  def message(err) do
    "HTTP request failed with status #{err.status_code}: #{inspect(err.reason)}"
  end
end
