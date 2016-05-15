defmodule Pushex.APNS.Callback do
  def error(error, token \\ "unknown token")
  def error({:error, reason}, _token) when reason in ~w(invalid_token_size)a do
    # already handled
  end
  def error(error, token) do
    Pushex.EventManager.handle_error(error, token)
  end

  def feedback(feedback) do
    Pushex.EventManager.handle_feedback(feedback)
  end
end
