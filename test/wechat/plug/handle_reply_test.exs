defmodule Wechat.Plugs.HandleReplyTest do
  use ExUnit.Case, async: false
  use Plug.Test

  defmodule SimpleHandler do
    use Wechat.Message.Responder
  end

  defmodule DSLHandler do
    use Wechat.Message.DSL
  end

  test "#init" do
    result = Wechat.Plugs.HandleReply.init([handler: MHandler])
    assert result[:handler] == MHandler
  end

  test "#call without parsed message" do
    conn = conn("POST", "/")
    conn = Wechat.Plugs.HandleReply.call(conn, [handler: SimpleHandler])

    assert conn.private[:wechat_msg_replied] == false
    refute conn.halted
  end

  @message %{
    url:            "http://127.0.0.1",
    to_user_name:   "toUser",
    from_user_name: "fromUser",
    create_time:    "1237819237012",
    msg_type:       "text",
    content:        "hellworld",
    msg_id:         "123123890123",
  }

  test "#call with parsed message" do
    conn = conn("POST", "/") |> assign(:msg, @message)
    conn = Wechat.Plugs.HandleReply.call(conn, [handler: SimpleHandler])

    assert conn.assigns[:reply] |> is_map
    assert conn.private[:wechat_msg_replied] == true
    refute conn.halted
  end
end
