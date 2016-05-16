defmodule Pushex.APNS.Response do
  @moduledoc """
  `Pushex.APNS.Response` represents a result to an APNS request
  """

  defstruct [success: 0, failure: 0, results: []]

  @type t :: %__MODULE__{
    success: non_neg_integer,
    failure: non_neg_integer,
    results: [:ok | {:error, atom}]
  }
end
