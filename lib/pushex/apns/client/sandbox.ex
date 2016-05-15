defmodule Pushex.APNS.Client.Sandbox do
  @moduledoc false

  @behaviour Pushex.APNS.Client

  def send_notification(request) do
    if request.to == :bad_id do
      %Pushex.APNS.Response{failure: 1, results: [{:error, :invalid_token_size}]}
    else
      count = if request.registration_ids, do: Enum.count(request.registration_ids), else: 1
      results = List.duplicate(count, :ok)
      response = %Pushex.APNS.Response{success: count, results: results}
      {:ok, response}
    end
  end
end
