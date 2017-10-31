defmodule Pushex.APNS.Client.Sandbox do
  @moduledoc false

  @behaviour Pushex.APNS.Client

  def send_notification(request) do
    if request.to == :bad_id do
      {:error, %Pushex.APNS.Response{failure: 1, results: [{:error, :invalid_token_size}]}}
    else
      count = request.to |> List.wrap |> Enum.count
      results = List.duplicate(:ok, count)
      response = %Pushex.APNS.Response{success: count, results: results}
      {:ok, response}
    end
  end
end
