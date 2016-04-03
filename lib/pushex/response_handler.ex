defmodule Pushex.ResponseHandler do
  @moduledoc """
  This module defines the behaviour to handle notification responses.

  It can be used to log the responses or save them in a database for example.

  ## Examples

      defmodule MyResponseHandler do
        def handle_response(response, request, {pid, ref}) do
          # do whatever you want with the response and request
          # for example, logging or saving in a DB
        end
      end
  """

  @callback handle_response(
    response :: {:ok, Pushex.GCM.Response} | {:error, Pushex.GCM.HTTPError},
    request  :: Pushex.GCM.Request,
    info     :: {pid, reference}) :: :ok

  def handle_response(response, request, info) do
    Enum.each(response_handlers, &(&1.handle_response(response, request, info)))
  end

  defp response_handlers, do: Application.get_env(:pushex, :response_handlers)
end
