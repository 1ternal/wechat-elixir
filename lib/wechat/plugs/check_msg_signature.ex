if Code.ensure_loaded?(Plug) do
  defmodule Wechat.Plugs.CheckMsgSignature do
    @moduledoc """
    Plug to parse xml message.
    """

    import Plug.Conn

    alias Wechat.Utils.MsgParser
    alias Wechat.Utils.Signature
    alias Wechat.Utils.Cipher

    def init(_opts) do
      [
        appid: Wechat.appid,
        token: Wechat.token,
        encoding_aes_key: Wechat.encoding_aes_key
      ]
    end

    def call(%Plug.Conn{method: "GET"} = conn, _opt) do
      conn
    end
    def call(%Plug.Conn{params: params} = conn, opts) do
      conn
      |> parse_xml_body
      |> get_message(params, opts)
      |> handle_conn(conn)
    end

    defp parse_xml_body(%Plug.Conn{} = conn) do
      conn
      |> read_body
      |> elem(1)
      |> MsgParser.parse
    end

    defp get_message(%{encrypt: encrypted_message}, %{"msg_signature" => _} = params, opts) do
      appid            = Keyword.fetch!(opts, :appid)
      encoding_aes_key = Keyword.fetch!(opts, :encoding_aes_key)
      token            = Keyword.fetch!(opts, :token)

      with true          <- (valid_message?(encrypted_message, params, token) || :message_invalid),
           {^appid, xml} <- Cipher.decrypt(encrypted_message, encoding_aes_key),
           message       <- MsgParser.parse(xml)
      do
        {:ok, {:encrypt, message}}
      else
        :message_invalid       -> {:error, "invalid message"}
        _                      -> {:error, "message decrypte error"}
      end
    end
    defp get_message(message, %{"msg_signature" => _}, _opts) do
      {:ok, {:comp, message}}
    end
    defp get_message(message, _params, _opt) do
      {:ok, {:plain, message}}
    end

    defp handle_conn({:ok, {message_type, message}}, conn) do
      conn
      |> assign(:msg, message)
      |> assign(:msg_type, message_type)
    end
    defp handle_conn({:error, err_msg}, conn) do
      conn
      |> send_resp(400, err_msg)
      |> halt
    end

    defp valid_message?(msg, %{"timestamp" => timestamp, "nonce" => nonce, "msg_signature" => signature}, token) do
      Signature.valid?(signature, [token, timestamp, nonce, msg])
    end
    defp valid_message?(_, _, _), do: false
  end
end
