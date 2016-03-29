defmodule Pushex.GCM.Client.HTTP do
  use HTTPoison.Base

  @behaviour Pushex.GCM.Client

  @endpoint Application.get_env(:pushex, :gcm)[:endpoint]

  @expected_fields ~w(multicast_id success failure canonical_ids results)

  def process_url(url) do
    Path.join(@endpoint, url)
  end

  defp process_request_body(body) when is_binary(body), do: body
  defp process_request_body(body) do
    Poison.encode!(body)
  end

  defp process_request_headers(headers) when is_map(headers) do
    Enum.into(headers, [])
  end
  defp process_request_headers(headers) do
    [{"Content-Type", "application/json"} | headers]
  end

  def send_notification(notification) do
    headers = [{"Authorization", "key=#{notification.app.auth_key}"}]
    post("send", notification, headers) |> process_notification_response
  end

  defp process_notification_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    response = body
    |> Poison.decode!
    |> Dict.take(@expected_fields)
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
    {:ok, struct(Pushex.GCM.Response, response)}
  end
  defp process_notification_response({:ok, %HTTPoison.Response{status_code: code, body: body}}) do
    {:error, %Pushex.GCM.HTTPError{status_code: code, reason: body}}
  end
  defp process_notification_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, %Pushex.GCM.HTTPError{status_code: 0, reason: reason}}
  end
end
