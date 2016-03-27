defmodule Pushex.GCM.Client do
  use HTTPoison.Base

  @endpoint Application.get_env(:pushex, :gcm)[:endpoint]

  @expected_fields ~w(multicast_id success failure canonical_ids results failed_registration_ids)

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

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> Dict.take(@expected_fields)
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
  end

  def send_notification(notification) do
    headers = [{"Authorization", "key=#{notification.app.auth_key}"}]
    post!("send", notification, headers)
  end
end
