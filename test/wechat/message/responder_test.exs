defmodule Wechat.Message.ResponderTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule UB do
    use Wechat.Message.Responder

    def before_reply(_msg) do
      raise "this func called"
    end
  end

  test "send_reply imported" do
    assert function_exported?(UB, :send_reply, 1)
    assert function_exported?(UB, :send_reply, 2)
  end

  test "override before_send" do
    assert_raise RuntimeError, fn ->
      conn("POST", "/") |> UB.send_reply
    end
  end

  describe "handle message" do
    defmodule RB do
      use Wechat.Message.Responder

      def handle_message(:text, %{content: "hello"} = msg) do
        text(msg, "hello pattern matched")
      end
      def handle_message(:text, msg) do
        text(msg, "hello not matched")
      end

      def handle_message(:image, %{image: %{pic_url: "www.qq.com/lorem"}} = msg) do
        text(msg, "www.qq.com/lorem matched")
      end
      def handle_message(:image, msg) do
        text(msg, "www.qq.com/lorem not matched")
      end
    end

    test "#handle_message text pattern match" do
      txt = :text |> message |> Map.put(:content, "hello")
      result = RB.handle_message(:text, txt)
      assert result[:content] == "hello pattern matched"
    end

    test "#handle_message text not match" do
      txt = :text |> message |> Map.put(:content, "lorem not exist")
      result = RB.handle_message(:text, txt)
      assert result[:content] == "hello not matched"
    end

    test "#handle_message image pattern match" do
      txt = :image |> message |> Map.put(:image, %{pic_url: "www.qq.com/lorem"})
      result = RB.handle_message(:image, txt)
      assert result[:content] == "www.qq.com/lorem matched"
    end

    test "#handle_message image not match" do
      txt = :image |> message |> Map.put(:pic_url, "lorem not exist")
      result = RB.handle_message(:image, txt)
      assert result[:content] == "www.qq.com/lorem not matched"
    end
  end

  describe "fallback" do
    defmodule Fallback do
      use Wechat.Message.Responder
    end

    for type <- ~W(text image voice video shortvideo location link)a do
      test "#handle_message fallback #{type} type" do
        msg = unquote(type) |> message
        result = Fallback.handle_message(unquote(type), msg)
        assert result[:content] == "fallback"
      end

      test "#handle_event fallback #{type} type" do
        msg = unquote(type) |> message
        result = Fallback.handle_event(unquote(type), msg)
        assert result[:content] == "fallback"
      end
    end
  end

  msg_tpl = %{
    text: %{
      msg_type:       "text",
      content:        "this is a test",
    },

    image: %{
      msg_type:       "image",
      pic_url:        "this is url",
      media_id:       "media_id",
    },

    voice: %{
      msg_type:       "voice",
      media_id:       "media_id",
      format:         "Format",
      recognition:    "腾讯微信团队",
    },

    video: %{
      msg_type:       "video",
      media_id:       "media_id",
      thumb_media_id: "thumb_media_id",
    },

    shortvideo: %{
      msg_type:       "shortvideo",
      media_id:       "media_id",
      thumb_media_id: "thumb_media_id",
    },

    location: %{
      msg_type:       "location",
      location_x:     "23.134521",
      location_y:     "113.358803",
      scale:          "20",
      label:          "位置信息",
    },

    link: %{
      msg_type:       "link",
      title:          "公众平台官网链接",
      description:    "公众平台官网链接",
      url:            "url",
    },
  }
  for {type, tpl} <- msg_tpl do
    map = Macro.escape(tpl)
    def message(unquote(type)) do
      Map.merge(%{
        to_user_name:   "toUser",
        from_user_name: "fromUser",
        create_time:    1348831860,
        msg_id:         "1234567890123456",
      }, unquote(map))
    end
  end
end
