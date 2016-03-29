defmodule Pushex.GCM.Client.Sandbox do
  @behaviour Pushex.GCM.Client

  def send_notification(request) do
    if request.to == :bad_id do
      {:error, %Pushex.GCM.HTTPError{status_code: 401, reason: "not authorized"}}
    else
      count = if request.registration_ids, do: Enum.count(request.registration_ids), else: 1
      results = Enum.each(0..count, &(%{"message_id": "#{&1}:123456#{&1}"}))
      response = %Pushex.GCM.Response{canonical_ids: 0,
                                      success: count,
                                      multicast_id: 123456,
                                      results: results}
      {:ok, response}
    end
  end
end
