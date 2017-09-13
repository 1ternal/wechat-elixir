defmodule Wechat.Message.ReplyBuilderTest do
  use ExUnit.Case, async: true

  alias Wechat.Message.ReplyBuilder

  setup do
    bare_reply = %{
      from_user_name: "from_user_name",
      to_user_name:   "to_user_name",
      create_time:    System.system_time(:seconds)
    }

    {:ok, reply: bare_reply}
  end

  test "remove uneed attributes" do
    receive_message = %{
      content: "hello",
      create_time: "123123123",
      from_user_name: "from_user_name",
      msg_id: "123123123",
      msg_type: "text",
      to_user_name: "to_user_name",
      url: "http://localhost"
    }

    result = ReplyBuilder.type(receive_message, :image)

    refute Map.has_key?(result, :content)
    refute Map.has_key?(result, :msg_id)
    refute Map.has_key?(result, :url)
  end

  test "root element", %{reply: reply} do
    reply =
      reply
      |> ReplyBuilder.type("text")
      |> ReplyBuilder.from_user("from_user_modified")
      |> ReplyBuilder.to_user("to_user_modified")
      |> ReplyBuilder.create_time(100200325)

    assert reply[:msg_type]       == "text"
    assert reply[:from_user_name] == "from_user_modified"
    assert reply[:to_user_name]   == "to_user_modified"
    assert reply[:create_time]    == 100200325
  end

  describe "text message" do
    test "with pipe", %{reply: reply} do
      reply =
        reply
        |> ReplyBuilder.type(:text)
        |> ReplyBuilder.content("hello world")

      assert reply[:msg_type] == "text"
      assert reply[:content] == "hello world"
    end
    test "one call", %{reply: reply} do
      reply =
        reply
        |> ReplyBuilder.text("hello world")

      assert reply[:msg_type] == "text"
      assert reply[:content] == "hello world"
    end
  end

  describe "image message" do
    test "with pipe", %{reply: reply} do
      reply =
        reply
        |> ReplyBuilder.type(:image)
        |> ReplyBuilder.media_id("hello world")

      assert reply[:msg_type] == "image"
      assert Map.has_key?(reply, :image)
      assert reply[:image] == %{
        media_id: "hello world"
      }
    end
    test "one call", %{reply: reply} do
      reply =
        reply
        |> ReplyBuilder.image("hello world")

      assert reply[:msg_type] == "image"
      assert Map.has_key?(reply, :image)
      assert reply[:image] == %{
        media_id: "hello world"
      }
    end
  end

  describe "voice message" do
    test "with pipe", %{reply: reply} do
      reply =
        reply
        |> ReplyBuilder.type(:voice)
        |> ReplyBuilder.media_id("hello world")

      assert reply[:msg_type] == "voice"
      assert Map.has_key?(reply, :voice)
      assert reply[:voice] == %{
        media_id: "hello world"
      }
    end
    test "one call", %{reply: reply} do
      reply =
        reply
        |> ReplyBuilder.voice("hello world")

      assert reply[:msg_type] == "voice"
      assert Map.has_key?(reply, :voice)
      assert reply[:voice] == %{
        media_id: "hello world"
      }
    end
  end

  describe "video message" do
    test "with pipe", %{reply: reply} do
      reply =
        reply
        |> ReplyBuilder.type(:video)
        |> ReplyBuilder.media_id("hello world")
        |> ReplyBuilder.title("hello title")
        |> ReplyBuilder.description("hello description")

      assert reply[:msg_type] == "video"
      assert Map.has_key?(reply, :video)
      assert reply[:video] == %{
        media_id:    "hello world",
        title:       "hello title",
        description: "hello description",
      }
    end
    test "one call", %{reply: reply} do
      reply =
        reply
        |> ReplyBuilder.video([
          media_id:    "hello world",
          title:       "hello title",
          description: "hello description",
        ])

      assert reply[:msg_type] == "video"
      assert Map.has_key?(reply, :video)
      assert reply[:video] == %{
        media_id:    "hello world",
        title:       "hello title",
        description: "hello description",
      }

      reply =
        reply
        |> ReplyBuilder.video(%{
          media_id:    "hello world",
          title:       "hello title",
          description: "hello description",
        })

      assert reply[:msg_type] == "video"
      assert Map.has_key?(reply, :video)
      assert reply[:video] == %{
        media_id:    "hello world",
        title:       "hello title",
        description: "hello description",
      }
    end
  end

  describe "music message" do
    test "with pipe", %{reply: reply} do
      reply =
        reply
        |> ReplyBuilder.type(:music)
        |> ReplyBuilder.title("hello title")
        |> ReplyBuilder.description("hello description")
        |> ReplyBuilder.music_url("hello musicurl")
        |> ReplyBuilder.hq_music_url("hello hqmusicurl")
        |> ReplyBuilder.thumb_media_id("hello thumbmediaid")

      assert reply[:msg_type] == "music"
      assert Map.has_key?(reply, :music)
      assert reply[:music] == %{
        title:          "hello title",
        description:    "hello description",
        music_url:      "hello musicurl",
        hq_music_url:   "hello hqmusicurl",
        thumb_media_id: "hello thumbmediaid",
      }
    end
    test "one call", %{reply: reply} do
      reply =
        reply
        |> ReplyBuilder.music([
          title:          "hello title",
          description:    "hello description",
          music_url:      "hello musicurl",
          hq_music_url:   "hello hqmusicurl",
          thumb_media_id: "hello thumbmediaid",
        ])

      assert reply[:msg_type] == "music"
      assert Map.has_key?(reply, :music)
      assert reply[:music] == %{
        title:          "hello title",
        description:    "hello description",
        music_url:      "hello musicurl",
        hq_music_url:   "hello hqmusicurl",
        thumb_media_id: "hello thumbmediaid",
      }

      reply =
        reply
        |> ReplyBuilder.music(%{
          title:          "hello title",
          description:    "hello description",
          music_url:      "hello musicurl",
          hq_music_url:   "hello hqmusicurl",
          thumb_media_id: "hello thumbmediaid",
        })

      assert reply[:msg_type] == "music"
      assert Map.has_key?(reply, :music)
      assert reply[:music] == %{
        title:          "hello title",
        description:    "hello description",
        music_url:      "hello musicurl",
        hq_music_url:   "hello hqmusicurl",
        thumb_media_id: "hello thumbmediaid",
      }
    end
  end

  describe "news message" do
    test "all in", %{reply: reply} do
      a1 = [
        title:       "hello title 1",
        description: "hello description 1",
        pic_url:     "hello pic_url 1",
        url:         "hello url 1",
      ]
      a2 = %{
        title:       "hello title 2",
        description: "hello description 2",
        pic_url:     "hello pic_url 2",
        url:         "hello url 2",
      }
      reply = reply
              |> ReplyBuilder.type(:news)
              |> ReplyBuilder.article(a1)
              |> ReplyBuilder.article(a2)

      assert reply[:msg_type] == "news"
      assert reply[:article_count] == 2
      assert length(reply[:articles]) == 2

      [item: ra1, item: ra2] = reply[:articles]

      assert ra1 == Enum.into(a1, %{})
      assert ra2 == a2
    end
  end
end
