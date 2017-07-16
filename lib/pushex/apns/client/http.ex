defmodule Pushex.APNS.Client.HTTP do
  @moduledoc false

  require Logger

  @behaviour Pushex.APNS.Client

  def send_notification(request) do
    make_messages(request)
    |> Enum.map(&log_and_send(request.app, &1))
    |> generate_response()
  end

  defp log_and_send(app, message) do
    to_log = Map.put(message, :token, String.slice(message.token, 0..10) <> "...")
    Logger.debug("sending message to apns using #{app.name}: #{inspect(to_log)}")
    Pushex.APNS.Worker.send_message(app, message)
  end

  @doc false
  def make_messages(request) do
    base_message = Pushex.APNS.Request.to_message(request)
    Enum.map(List.wrap(request.to), &Map.put(base_message, :token, &1))
  end

  @doc false
  def generate_response(results) do
    List.foldr results, %Pushex.APNS.Response{}, fn
      :ok, response ->
        %{response | success: response.success + 1, results: [:ok | response.results]}
      {:error, _reason} = err, response ->
        %{response | failure: response.failure + 1, results: [err | response.results]}
    end
  end
end
