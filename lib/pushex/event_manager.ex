defmodule Pushex.EventManager do
  @moduledoc false

  def handle_request(request, info) do
    GenEvent.notify(__MODULE__, {:request, request, info})
  end

  def handle_response(response, request, info) do
    GenEvent.notify(__MODULE__, {:response, response, request, info})
  end

  def handle_error(error, token) do
    GenEvent.notify(__MODULE__, {:error, error, token})
  end

  def handle_feedback(feedback) do
    GenEvent.notify(__MODULE__, {:feedback, feedback})
  end
end
