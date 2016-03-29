defmodule Pushex.ResponseHandler.Noop do
  @behaviour Pushex.ResponseHandler

  def handle_response(_response, _request, _info) do
    :ok
  end
end
