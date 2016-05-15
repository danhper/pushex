defmodule Pushex.APNS.Client.SSL do
  @moduledoc false

  @behaviour Pushex.APNS.Client

  def send_notification(request) do
    base_message = Pushex.APNS.Request.to_message(request)
    app = request.app
    Enum.map List.wrap(request.to), fn token ->
      message = Map.put(base_message, :token, token)
      APNS.push_sync(app, message)
    end
    |> generate_response()
  end

  defp generate_response(results) do
    response = Enum.reduce results, %Pushex.APNS.Response{}, fn result, response ->
      case result do
        :ok ->
          %{response | success: response.success + 1,
                       results: [:ok | response.results]}
        {:error, _reason} = err ->
          %{response | failure: response.failure + 1,
                       results: [err | response.results]}
      end
    end
    Map.put(response, :results, Enum.reverse(response.results))
  end
end
