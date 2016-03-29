defmodule Pushex.GCM.Response do
  @moduledoc """
  `Pushex.GCM.Response` represents a GCM response.

  When `canonical_ids` is greater than `0`, `results` should be checked
  and the registration ids should be updated consequently.
  This should be done in a custom `ResponseHandler`.

  See https://developers.google.com/cloud-messaging/http#response for more info
  """

  defstruct [:multicast_id, :success, :failure, :canonical_ids, :results]

  @type t :: %__MODULE__{
    multicast_id: integer,
    success: non_neg_integer,
    failure: non_neg_integer,
    canonical_ids: non_neg_integer,
    results: [%{String.t => String.t}]
  }
end
