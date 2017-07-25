defmodule Pushex.EventManager do
  @moduledoc false

  def handle_request(request, info) do
    :gen_event.notify(__MODULE__, {:request, request, info})
  end

  def handle_response(response, request, info) do
    :gen_event.notify(__MODULE__, {:response, response, request, info})
  end

  def handle_error(error, token) do
    :gen_event.notify(__MODULE__, {:error, error, token})
  end

  def handle_feedback(feedback) do
    :gen_event.notify(__MODULE__, {:feedback, feedback})
  end
end
