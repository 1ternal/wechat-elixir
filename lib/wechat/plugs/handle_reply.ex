defmodule Wechat.Plugs.HandleReply do

  @behaviour Plug
  import Plug.Conn

  @replied_key :wechat_msg_replied

  def init(opt) do
    Keyword.merge([
      mod: Wechat.Message.Responder
    ], opt)
  end

  def call(conn, opts) do
    handler = Keyword.fetch!(opts, :mod)
    case msg = conn.assigns[:msg] do
      nil ->
        put_private(conn, @replied_key, false)
      %{} ->
        conn
        |> assign(:reply, apply(handler, :reply, [msg]))
        |> put_private(@replied_key, true)
    end
  end
end
