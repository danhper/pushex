defmodule Pushex.APNS.JWTManager do
  use GenServer

  @expiration_seconds 3600

  def start_link(expiration \\ @expiration_seconds) do
    GenServer.start_link(__MODULE__, %{expiration: expiration}, name: __MODULE__)
  end

  def init(%{expiration: expiration}) do
    {:ok, %{tokens: %{}, expiration: expiration}}
  end

  def fetch_token(app) do
    GenServer.call(__MODULE__, {:fetch_token, app}, 1000)
  end

  def handle_call({:fetch_token, app}, _from, %{tokens: tokens, expiration: expiration} = state) do
    {token, new_tokens} = do_fetch_token(app, tokens, expiration)
    {:reply, token, Map.put(state, :tokens, new_tokens)}
  end

  defp do_fetch_token(app, tokens, expiration) do
    timestamp = DateTime.to_unix(DateTime.utc_now(), :seconds)
    case Map.get(tokens, app.name) do
      {token, expires_at} when expires_at > timestamp ->
        {token, tokens}
      _ ->
        token = Pushex.APNS.JWT.generate_token(app)
        {token, Map.put(tokens, app.name, {token, timestamp + expiration})}
    end
  end
end
