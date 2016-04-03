defmodule Pushex.GCM do
  @moduledoc "This module defines types to work with GCM"

  @type response :: {:ok, Pushex.GCM.Response} | {:error, Pushex.GCM.HTTPError}
  @type request :: Pushex.GCM.Request.t
end
