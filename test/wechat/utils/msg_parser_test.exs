defmodule Wechat.Utils.MsgParserTest do
  use ExUnit.Case, async: true

  alias Wechat.Utils.MsgParser, as: Parser

  incoming_mapping = %{
    from_user_name: "FromUserName",
    to_user_name:   "ToUserName",
    msg_type:       "MsgType",
    create_time:    "CreateTime",
    msg_id:         "MsgId",
    content:        "Content",
    media_id:       "MediaId",
    pic_url:        "PicUrl",
    format:         "Format",
    recognition:    "Recognition",
    thumb_media_id: "ThumbMediaId",
    location_x:     "Location_X",
    location_y:     "Location_Y",
    scale:          "Scale",
    label:          "Label",
    title:          "Title",
    description:    "Description",
    url:            "Url",
    encrypt:        "Encrypt",

    article_count:   "ArticleCount",
    articles:        "Articles",
    hq_music_url:    "HQMusicUrl",
    music_url:       "MusicUrl",
  }

  for {atom, xml_key} <- incoming_mapping do
    test "#parse #{xml_key}" do
      result = Parser.parse(xml_tpl(unquote(xml_key)))
      assert Map.has_key?(result, unquote(atom))
    end

    test "#restore #{atom}" do
      result = Parser.restore(Map.put(%{}, unquote(atom), "whatever"))
      assert Map.has_key?(result, unquote(xml_key))
    end
  end

  test "#restore complex reply" do
    reply = %{
      to_user_name:   "lorem root leval",
      from_user_name: "lorem root leval",
      create_time:    "lorem root leval",
      msg_type:       "lorem root leval",
      article_count: 2,
      articles: [
        item: %{
          title:       "lorem item 1",
          description: "lorem item 1",
          pic_url:     "lorem item 1",
          url:         "lorem item 1",
        },
        item: %{
          title:       "lorem item 2",
          description: "lorem item 2",
          pic_url:     "lorem item 2",
          url:         "lorem item 2",
        }
      ]
    }

    result = Parser.restore(reply)

    assert result["ToUserName"]
    assert result["FromUserName"]
    assert result["CreateTime"]
    assert result["MsgType"]
    assert result["ArticleCount"]

    [i1, i2] = Keyword.values(result["Articles"])
    assert i1 == %{
      "Title"       => "lorem item 1",
      "Description" => "lorem item 1",
      "PicUrl"      => "lorem item 1",
      "Url"         => "lorem item 1",
    }
    assert i2 == %{
      "Title"       => "lorem item 2",
      "Description" => "lorem item 2",
      "PicUrl"      => "lorem item 2",
      "Url"         => "lorem item 2",
    }
  end

  defp xml_tpl(k) do
    ~s|<xml><#{k}>whatever</#{k}></xml>|
  end
end
