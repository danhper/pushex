defmodule Pushex.GCM.Response do
  defstruct [:multicast_id, :success, :failure, :canonical_ids, :results]

  @type t :: %__MODULE__{
    multicast_id: integer,
    success: non_neg_integer,
    failure: non_neg_integer,
    canonical_ids: non_neg_integer,
    results: [%{String.t => String.t}]
  }
end
