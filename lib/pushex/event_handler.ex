defmodule Pushex.EventHandler do
  @moduledoc """
  This module defines utilities to handle events when sending notification.

  Events can be implemented to log requests, responses or save them in a database for example.

  Under the hood, it uses a `GenEvent`, so you will basically need to implement
  `handle_event` for the events you care about.

  The following events are emitted:

    * `{:request, request, {pid, ref}}`
    * `{:response, response, request, {pid, ref}}`

  ## Examples

  defmodule MyPushEventHandler do
    use Pushex.EventHandler

    def handle_event({:response, response, request, {pid, ref}}, state) do
      # do whatever you want with the request
      # for example, logging or saving in a DB
    end

    def handle_event({:response, response, request, {pid, ref}}, state) do
      # do whatever you want with the response and request
    end
  end
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      use GenEvent
      @before_compile {unquote(__MODULE__), :add_default_handlers}
    end
  end

  @doc false
  defmacro add_default_handlers(_env) do
    quote line: -1 do
      def handle_event({:request, _request, _info}, state) do
        {:ok, state}
      end

      def handle_event({:response, _response, _request, _info}, state) do
        {:ok, state}
      end
    end
  end
end
