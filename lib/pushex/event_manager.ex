defmodule Pushex.EventManager do
  @moduledoc false

  def handle_request(request, info) do
    GenEvent.notify(__MODULE__, {:request, request, info})
  end

  def handle_response(response, request, info) do
    GenEvent.notify(__MODULE__, {:response, response, request, info})
  end
end
