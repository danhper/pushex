defmodule Pushex.EventManager do
  @moduledoc """
  This module defines the behaviour to handle events when sending notification.

  Events can be implemented to log the responses or save them in a database for example.

  ## Examples

      defmodule MyResponseHandler do
        def handle_response(response, request, {pid, ref}) do
          # do whatever you want with the response and request
          # for example, logging or saving in a DB
        end
      end
  """

  @callback handle_response(
    response :: Pushex.GCM.response,
    request  :: Pushex.GCM.request,
    info     :: {pid, reference}) :: :ok


  def handle_request(request, info) do
    GenEvent.notify(__MODULE__, {:request, request, info})
  end

  def handle_response(response, request, info) do
    GenEvent.notify(__MODULE__, {:response, request, response, info})
  end
end
