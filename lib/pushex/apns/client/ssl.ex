defmodule Pushex.APNS.Client.SSL do
  @moduledoc false

  @behaviour Pushex.APNS.Client

  alias Pushex.APNS.SSLPoolManager

  def send_notification(request) do
    SSLPoolManager.ensure_pool_started(request.app)

    make_messages(request)
    |> Enum.map(&APNS.push_sync(request.app.name, &1))
    |> generate_response()
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
