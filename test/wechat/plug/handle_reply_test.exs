defmodule Wechat.Plugs.HandleReplyTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule SimpleHandler do
    def reply(message) do
      message
    end
  end

  test "#init" do
    result = Wechat.Plugs.HandleReply.init([])
    assert result[:mod] == Wechat.Message.Responder

    result = Wechat.Plugs.HandleReply.init(mod: SimpleHandler)
    assert result[:mod] == SimpleHandler
  end

  test "#call without parsed message" do
    conn = conn("POST", "/")
    conn = Wechat.Plugs.HandleReply.call(conn, [mod: SimpleHandler])

    assert conn.private[:wechat_msg_replied] == false
    refute conn.halted
  end

  @message %{
    "URL" =>          "http://127.0.0.1",
    "ToUserName" =>   "toUser",
    "FromUserName" => "fromUser",
    "CreateTime" =>   "1237819237012",
    "MsgType" =>      "text",
    "Content" =>      "hellworld",
    "MsgId" =>        "123123890123",
  }

  test "#call with parsed message" do
    conn = conn("POST", "/") |> assign(:msg, @message)
    conn = Wechat.Plugs.HandleReply.call(conn, [mod: SimpleHandler])

    assert conn.assigns[:reply] |> is_map
    assert conn.private[:wechat_msg_replied] == true
    refute conn.halted
  end
end
