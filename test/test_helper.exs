ExUnit.start()

defmodule Pushex.DummyHandler do
  def handle_response(response, request, {pid, ref}) do
    send pid, {response, request, ref}
  end
end
