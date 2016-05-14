defmodule Pushex.APNS.App do
  @moduledoc """
  `Pushex.APNS.App` represents an APNS application.

  `:name` is a unique identifier used to find the application,
  `:certfile` is the certificate for the application, and `:env` is `:dev` or `:prod`.
  """

  defstruct [:name, :certfile, :env]
end
