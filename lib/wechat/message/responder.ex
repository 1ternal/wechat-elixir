defmodule Wechat.Message.Responder do
  @moduledoc """
  wechat message responder

  use Wechat.Message.Responder
  """

  alias Wechat.Utils.{Cipher, MsgParser}

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

  def send_reply(conn, message) do
    xml_msg =
      message
      |> MsgParser.restore
      |> maybe_encrypt_message(conn)
      |> MsgParser.build_xml

    conn
    |> Plug.Conn.put_resp_content_type("text/xml")
    |> Plug.Conn.send_resp(200, xml_msg)
  end

  defp maybe_encrypt_message(message, %Plug.Conn{assigns: %{msg_type: :encrypt}}) do
    encoding_ase_key = Wechat.encoding_aes_key
    token            = Wechat.token
    Cipher.encrypt_message(message, encoding_ase_key, token)
  end

  defp maybe_encrypt_message(message, %Plug.Conn{assigns: %{msg_type: t}}) when t in [:plain, :comp] do
    message
  end
end
