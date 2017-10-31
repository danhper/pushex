defmodule Pushex.EventHandler do
  @moduledoc """
  This module defines utilities to handle events when sending notification.

  Events can be implemented to log requests, responses or save them in a database for example.

  Under the hood, it uses a `:gen_event`, so you will need to implement
  `handle_event` for the events you care about.

  The following events are emitted:

    * `{:request, request, {pid, ref}}`
    * `{:response, response, request, {pid, ref}}`

  ## Examples

  defmodule MyPushEventHandler do
    use Pushex.EventHandler

    def handle_event({:request, request, {pid, ref}}, state) do
      # do whatever you want with the request
      # for example, logging or saving in a DB
      {:ok, state}
    end

    def handle_event({:response, response, request, {pid, ref}}, state) do
      # do whatever you want with the response and request
      {:ok, state}
    end
  end
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      @behaviour :gen_event
      @before_compile {unquote(__MODULE__), :add_default_handlers}
    end
  end

  @doc false
  defmacro add_default_handlers(_env) do
    quote do
      def init(args), do: {:ok, args}
      def handle_call(_request, state), do: {:ok, :ok, state}
      def handle_info(_info, state), do: {:ok, state}
      def code_change(_old_vsn, state, _extra), do: state
      def terminate(args, _state), do: :ok

      def handle_event({:request, _request, _info}, state), do: {:ok, state}
      def handle_event({:response, _response, _request, _info}, state), do: {:ok, state}
      def handle_event({:error, _error, _token}, state), do: {:ok, state}
      def handle_event({:feedback, _feedback}, state), do: {:ok, state}
    end
  end
end
