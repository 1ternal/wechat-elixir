defmodule Wechat.Message.ResponderTest do
  use ExUnit.Case, async: true

  defmodule A do
    use Wechat.Message.Responder

    def handle_message(:text, %{content: "hello"} = msg) do
      Map.put(msg, :content, "hello pattern matched")
    end

    def handle_message(:text, msg) do
      Map.put(msg, :content, "hello not matched")
    end

    def handle_message(:image, %{pic_url: "www.qq.com/lorem"} = msg) do
      Map.put(msg, :pic_url, "www.qq.com/lorem matched")
    end

    def handle_message(:image, msg) do
      Map.put(msg, :pic_url, "www.qq.com/lorem not matched")
    end
  end

  test "#handle_message text pattern match" do
    txt = :text |> message |> Map.put(:content, "hello")
    result = A.handle_message(:text, txt)
    assert result[:content] == "hello pattern matched"
  end

  test "#handle_message text not match" do
    txt = :text |> message |> Map.put(:content, "lorem not exist")
    result = A.handle_message(:text, txt)
    assert result[:content] == "hello not matched"
  end

  test "#handle_message image pattern match" do
    txt = :image |> message |> Map.put(:pic_url, "www.qq.com/lorem")
    result = A.handle_message(:image, txt)
    assert result[:pic_url] == "www.qq.com/lorem matched"
  end

  test "#handle_message image not match" do
    txt = :image |> message |> Map.put(:pic_url, "lorem not exist")
    result = A.handle_message(:image, txt)
    assert result[:pic_url] == "www.qq.com/lorem not matched"
  end

  defmodule Fallback do
    use Wechat.Message.Responder
  end

  for type <- ~W(text image voice video shortvideo location link)a do
    test "#handle_message fallback with #{type} type" do
      msg = unquote(type) |> message

      result = Fallback.handle_message(unquote(type), msg)

      assert result[:content] == "fallback"
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
