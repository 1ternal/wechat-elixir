defmodule Wechat.Plugs.HandleReply do

  @behaviour Plug
  import Plug.Conn

  @replied_key :wechat_msg_replied

  def init(opt) do
    handler =
      Keyword.get(opt, :handler) ||
      Application.get_env(:wechat, Wechat)[:message_handler] ||
      Wechat.Message.Responder
    [handler: handler]
  end

  def call(conn, opts) do
    handler = Keyword.fetch!(opts, :handler)

    case msg = conn.assigns[:msg] do
      nil ->
        put_private(conn, @replied_key, false)
      %{} ->
        reply = handle_reply(handler, msg)
        conn
        |> assign(:reply, reply)
        |> put_private(@replied_key, true)
    end
  end

  defp handle_reply(handler, msg) do
    if function_exported?(handler, :reply, 1) do
      apply(handler, :reply, [msg])
    else
      case msg do
        %{msg_type: "event"} -> handle_event(handler, msg)
        _                    -> handle_message(handler, msg)
      end
    end
  end

  defp handle_event(handler, %{event: event_type} = msg),
    do: apply(handler, :handle_event, [downcase_atom(event_type), msg])

  defp handle_message(handler, %{msg_type: msg_type} = msg),
    do: apply(handler, :handle_message, [downcase_atom(msg_type), msg])

  defp downcase_atom(str), do: str |> String.downcase |> String.to_atom
end
