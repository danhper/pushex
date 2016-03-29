defmodule Pushex.ResponseHandler do
  @module """
  This module defines the behaviour to handle notification responses.

  It can be used to log the responses or save them in a database for example.
  """

  @callback handle_response(
    response :: {:ok, Pushex.GCM.Response} | {:error, Pushex.GCM.HTTPError},
    request  :: Pushex.GCM.Request,
    info     :: {pid, reference}) :: :ok

  def handle_response(response, request, info) do
    impl.handle_response(response, request, info)
  end

  defp impl, do: Application.get_env(:pushex, :response_handler_impl)
end
