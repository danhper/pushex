defmodule Pushex.APNS.JWTManager do
  use GenServer

  @expiration_milliseconds 60 * 60 * 1000

  def start_link(expiration \\ @expiration_milliseconds, options) do
    GenServer.start_link(__MODULE__, %{expiration: expiration}, options)
  end

  def init(%{expiration: expiration}) do
    {:ok, %{tokens: %{}, expiration: expiration}}
  end

  def fetch_token(app, pid \\ __MODULE__) do
    GenServer.call(pid, {:fetch_token, app}, 1000)
  end

  def handle_call({:fetch_token, app}, _from, %{tokens: tokens, expiration: expiration} = state) do
    {token, new_tokens} = do_fetch_token(app, tokens, expiration)
    {:reply, token, Map.put(state, :tokens, new_tokens)}
  end

  defp do_fetch_token(%Pushex.APNS.App{name: app_name} = app, tokens, expiration) do
    timestamp = DateTime.to_unix(DateTime.utc_now(), :milliseconds)
    case Map.get(tokens, app_name) do
      {token, expires_at} when expires_at > timestamp ->
        {token, tokens}
      _ ->
        token = Pushex.APNS.JWT.generate_token(app)
        {token, Map.put(tokens, app_name, {token, timestamp + expiration})}
    end
  end
end
