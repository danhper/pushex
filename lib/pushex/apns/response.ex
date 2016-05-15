defmodule Pushex.APNS.Response do
  @moduledoc """
  `Pushex.APNS.Response` represents a result to an APNS request
  """

  defstruct [:multicast_id, :success, :failure, :canonical_ids, :results]

  @type t :: %__MODULE__{
    multicast_id: integer,
    success: non_neg_integer,
    failure: non_neg_integer,
    results: [:ok | {:error, atom}]
  }
end
