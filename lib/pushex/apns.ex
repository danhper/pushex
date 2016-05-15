defmodule Pushex.APNS do
  @moduledoc "This module defines types to work with APNS"

  @type response :: {:ok, Pushex.APNS.Response} | {:error, atom}
  @type request :: Pushex.APNS.Request.t
end
