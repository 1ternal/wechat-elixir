defmodule Wechat.Message.Responder do
  @moduledoc """
  wechat message responder

  use Wechat.Message.Responder
  """

  defmacro __using__(_opt) do
    quote do
      import Wechat.Message.ReplyBuilder

      def send_reply(conn), do: send_reply(conn, conn.assigns[:reply])
      def send_reply(conn, msg) do
        Wechat.Message.Responder.send_reply(conn, before_reply(msg))
      end

      def before_reply(msg), do: msg
      defoverridable [before_reply: 1]
      @before_compile(unquote(__MODULE__))
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def handle_message(_t, msg) do
        msg
        |> Wechat.Message.ReplyBuilder.type(:text)
        |> Wechat.Message.ReplyBuilder.text("fallback")
      end
      def handle_event(_t, msg) do
        msg
        |> Wechat.Message.ReplyBuilder.type(:text)
        |> Wechat.Message.ReplyBuilder.text("fallback")
      end
    end
  end
end
