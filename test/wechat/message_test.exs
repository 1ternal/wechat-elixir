defmodule Wechat.MessageTest do
  use ExUnit.Case

  alias Wechat.Message

  describe "message setter" do
    test "text" do
      msg =
        bare_reply()
        |> Message.msg_type("text")
        |> Message.to_user_name("zhangsan")
        |> Message.from_user_name("lisi")
        |> Message.create_time(1231412124)
        |> Message.content("helloworld")

      assert msg["ToUserName"]   == "zhangsan"
      assert msg["FromUserName"] == "lisi"
      assert msg["CreateTime"]   == 1231412124
      assert msg["MsgType"]      == "text"
      assert msg["Content"]      == "helloworld"
    end

    test "image" do
      msg1 =
        bare_reply()
        |> Message.msg_type("image")
        |> Message.media_id("some_media_id")

      msg2 = Message.image(bare_reply(), media_id: "some_media_id")

      for msg <- [msg1, msg2] do
        assert msg["MsgType"] == "image"
        assert Map.has_key?(msg, "Image")
        assert get_in(msg, ["Image", "MediaId"]) == "some_media_id"
      end
    end

    test "video" do
      msg1 =
        bare_reply()
        |> Message.msg_type("video")
        |> Message.media_id("lorem")
        |> Message.title("lorem")
        |> Message.description("lorem")

      msg2 = Message.video(bare_reply(), media_id: "lorem", title: "lorem", description: "lorem")

      for msg <- [msg1, msg2] do
        assert msg["MsgType"] == "video"
        assert Map.has_key?(msg, "Video")
        assert get_in(msg, ["Video", "MediaId"])     == "lorem"
        assert get_in(msg, ["Video", "Description"]) == "lorem"
        assert get_in(msg, ["Video", "Title"])       == "lorem"
      end
    end

    test "music" do
      msg1 =
        bare_reply()
        |> Message.msg_type("music")
        |> Message.media_id("lorem media_id")
        |> Message.title("lorem title")
        |> Message.description("lorem description")
        |> Message.music_url("lorem music_url")
        |> Message.hq_music_url("lorem hq_music_url")
        |> Message.thumb_media_id("lorem thumb_media_id")

      msg2 = Message.music(bare_reply(), title:          "lorem title",
                                         description:    "lorem description",
                                         music_url:      "lorem music_url",
                                         hq_music_url:   "lorem hq_music_url",
                                         thumb_media_id: "lorem thumb_media_id")
      for msg <- [msg1, msg2] do
        assert msg["MsgType"] == "music"
        assert Map.has_key?(msg, "Music")
        assert get_in(msg, ["Music", "Title"])        == "lorem title"
        assert get_in(msg, ["Music", "Description"])  == "lorem description"
        assert get_in(msg, ["Music", "MusicUrl"])     == "lorem music_url"
        assert get_in(msg, ["Music", "HQMusicUrl"])   == "lorem hq_music_url"
        assert get_in(msg, ["Music", "ThumbMediaId"]) == "lorem thumb_media_id"
      end
    end

    test "article" do
      a1 = [
        title: "a1 Title",
        description: "a1 Description",
        pic_url: "a1 PicUrl",
        url: "a1 Url",
      ]

      a2 = [
        title: "a2 Title",
        description: "a2 Description",
        pic_url: "a2 PicUrl",
        url: "a2 Url",
      ]

      msg =
        bare_reply()
        |> Message.msg_type("article")
        |> Message.article(a1)
        |> Message.article(a2)

      assert msg["ArticleCount"] == 2
      assert length(msg["Articles"]) == 2

      a1_map = for {k, v} <- a1, into: %{} do
        {Macro.camelize("#{k}"), v}
      end

      a2_map = for {k, v} <- a2, into: %{} do
        {Macro.camelize("#{k}"), v}
      end
      {a1, rest} = Keyword.pop_first(msg["Articles"], :item)
      assert a1 == a1_map
      {a2, _} = Keyword.pop_first(rest, :item)
      assert a2 == a2_map
    end
  end

  # describe "message getter" do
  #   test "text message" do
  #     msg = %{
  #       "ToUserName"   => "toUser",
  #       "FromUserName" => "fromUser",
  #       "CreateTime"   => 1348831860,
  #       "MsgType"      => "text",
  #       "Content"      => "helloworld"
  #     }
  #     assert Message.to_user_name(msg)   == "toUser"
  #     assert Message.from_user_name(msg) == "fromUser"
  #     assert Message.create_time(msg)    == 1348831860
  #     assert Message.msg_type(msg)       == "text"
  #     assert Message.content(msg)        == "helloworld"
  #   end
  # end

  defp bare_reply do
    %{
      "ToUserName"   => "toUser",
      "FromUserName" => "fromUser",
      "CreateTime"   => 1348831860,
    }
  end
end
