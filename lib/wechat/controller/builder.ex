if Code.ensure_loaded?(Plug) do
  defmodule Wechat.Controller.Builder do
    @moduledoc """
    This module is the helper model for phoenix controller

    ## Example
    ```
      defmodule MyApp.WechatController do

        use Wechat.Controller.Builder

        plug Wechat.Plugs.CheckUrlSignature
        plug Wechat.Plugs.CheckMsgSignature when action in [:create]

        def index(conn, %{"echostr" => echostr}, _) do
          if conn.assigns[:url_checked] do
            text(conn, echostr)
          else
            send_resp(conn, 400, "")
          end
        end

        def create(conn, _params, message) do
          message
          |> switch_user
          |> reply(conn)
        end

        defp switch_user(%{"FromUserName" => from, "ToUserName" => to} = message) do
          %{message | "FromUserName" => to, "ToUserName" => from}
        end
      end
    ```
    """

    @doc false
    defmacro __using__(_opts) do
      quote do
        import unquote(__MODULE__)

        plug Wechat.Plugs.HandleReply,
          mod: Application.get_env(:wechat, Wechat)[:message_handler]

        def action(conn, _opt) do
          args = [conn, conn.params, {conn.assigns[:msg], conn.assigns[:reply]}]
          apply(__MODULE__, action_name(conn), args)
        end

        defoverridable [action: 2]
      end
    end

    def reply(conn) do
      reply_message = conn.assigns[:reply]
      reply(conn, reply_message)
    end
    def reply(conn, message) do
      message = Wechat.Utils.MsgParser.restore(message)
      IO.inspect(message)
      xml_msg =
        case conn.assigns[:msg_type] do
          :encrypt ->
            message |> do_encrypt |> build_xml
          t when t in [:plain, :comp] ->
            build_xml(message)
        end

      conn
      |> Plug.Conn.put_resp_content_type("text/xml")
      |> Plug.Conn.send_resp(200, xml_msg)
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
