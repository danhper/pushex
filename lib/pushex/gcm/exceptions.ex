defmodule Pushex.GCM.HTTPError do
  @moduledoc """
  `Pushex.GCM.HTTPError` represents a failed request to GCM API.
  """

  defexception [:status_code, :reason]

  @type t :: %__MODULE__{
    status_code: non_neg_integer,
    reason: String.t
  }

  def message(err) do
    "HTTP request failed with status #{err.status_code}: #{inspect(err.reason)}"
  end
end
