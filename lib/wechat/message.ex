defmodule Wechat.Message do
  @moduledoc """
  message plug responder

  def MyAppWeb.WechatController

    plug Wechat.Plugs.CheckUrlSignature
    plug Wechat.Plugs.CheckMsgSignature when action in [:create]
    plug Wechat.Plugs.HandleReply, mod: ChattyWeb.Handler
    use Wechat.Message, :controller
  end
  """

  defmacro __using__(opt) do
    apply(__MODULE__, opt, [])
  end

  def controller do
    quote do
      def reply(conn),      do: Wechat.Message.Plug.reply(conn)
      def reply(conn, msg), do: Wechat.Message.Plug.reply(conn, msg)
    end
  end

  defmodule Plug do
    def reply(conn) do
      reply_message = conn.assigns[:reply]
      reply(conn, reply_message)
    end
    def reply(conn, message) do
      message = Wechat.Utils.MsgParser.restore(message)
      xml_msg =
        case conn.assigns[:msg_type] do
          :encrypt ->
            message |> do_encrypt |> build_xml
          t when t in [:plain, :comp] ->
            build_xml(message)
        end

      conn
      |> :"Elixir.Plug.Conn".put_resp_content_type("text/xml")
      |> :"Elixir.Plug.Conn".send_resp(200, xml_msg)
    end

    defp do_encrypt(reply) do
      encoding_ase_key = Wechat.encoding_aes_key
      message          = Wechat.Utils.Cipher.encrypt(build_xml(reply), encoding_ase_key)

      token     = Wechat.token
      timestamp = DateTime.utc_now |> DateTime.to_unix
      nonce     = Base.encode16(:crypto.strong_rand_bytes(5), case: :lower)
      signature = Wechat.Utils.Signature.sign([token, timestamp, nonce, message])

      %{
        "Encrypt"      => message,
        "MsgSignature" => signature,
        "TimeStamp"    => timestamp,
        "Nonce"        => nonce,
      }
    end

    defp build_xml(reply) do
      content =
        reply
        |> do_build_xml
        |> XmlBuilder.generate
      "<xml>#{content}</xml>"
    end

    defp do_build_xml(result) do
      result
      |> Enum.map(fn {k, v} ->
        case v do
          v when is_list(v) or is_map(v) -> XmlBuilder.element(k, nil, do_build_xml(v))
          v when is_nil(v) -> XmlBuilder.element(k, nil, "")
          _                -> XmlBuilder.element(k, nil, v)
        end
      end)
    end
  end
end
