# defmodule Wechat.MessageTest do
#   use ExUnit.Case

#   alias Wechat.Message

#   describe "message setter" do
#     test "text" do
#       msg =
#         bare_reply()
#         |> Message.msg_type("text")
#         |> Message.to_user_name("zhangsan")
#         |> Message.from_user_name("lisi")
#         |> Message.create_time(1231412124)
#         |> Message.content("helloworld")

#       assert msg[:to_user_name]   == "zhangsan"
#       assert msg[:from_user_name] == "lisi"
#       assert msg[:create_time]    == 1231412124
#       assert msg[:msg_type]       == "text"
#       assert msg[:content]        == "helloworld"
#     end

#     test "image" do
#       msg1 =
#         bare_reply()
#         |> Message.msg_type("image")
#         |> Message.media_id("some_media_id")

#       msg2 = Message.image(bare_reply(), media_id: "some_media_id")

#       for msg <- [msg1, msg2] do
#         assert msg[:msg_type] == "image"
#         assert Map.has_key?(msg, :image)
#         assert get_in(msg, [:image, :media_id]) == "some_media_id"
#       end
#     end

#     test "video" do
#       msg1 =
#         bare_reply()
#         |> Message.msg_type("video")
#         |> Message.media_id("lorem")
#         |> Message.title("lorem")
#         |> Message.description("lorem")

#       msg2 = Message.video(bare_reply(), media_id: "lorem", title: "lorem", description: "lorem")

#       for msg <- [msg1, msg2] do
#         assert msg[:msg_type] == "video"
#         assert Map.has_key?(msg, :video)
#         assert get_in(msg, [:video, :media_id])     == "lorem"
#         assert get_in(msg, [:video, :description]) == "lorem"
#         assert get_in(msg, [:video, :title])       == "lorem"
#       end
#     end

#     test "music" do
#       msg1 =
#         bare_reply()
#         |> Message.msg_type("music")
#         |> Message.media_id("lorem media_id")
#         |> Message.title("lorem title")
#         |> Message.description("lorem description")
#         |> Message.music_url("lorem music_url")
#         |> Message.hq_music_url("lorem hq_music_url")
#         |> Message.thumb_media_id("lorem thumb_media_id")

#       msg2 = Message.music(bare_reply(), title:          "lorem title",
#                                          description:    "lorem description",
#                                          music_url:      "lorem music_url",
#                                          hq_music_url:   "lorem hq_music_url",
#                                          thumb_media_id: "lorem thumb_media_id")
#       for msg <- [msg1, msg2] do
#         assert msg[:msg_type] == "music"
#         assert Map.has_key?(msg, :music)
#         assert get_in(msg, [:music, :title])          == "lorem title"
#         assert get_in(msg, [:music, :description])    == "lorem description"
#         assert get_in(msg, [:music, :music_url])      == "lorem music_url"
#         assert get_in(msg, [:music, :hq_music_url])   == "lorem hq_music_url"
#         assert get_in(msg, [:music, :thumb_media_id]) == "lorem thumb_media_id"
#       end
#     end

#     test "article" do
#       a1 = [
#         title: "a1 Title",
#         description: "a1 Description",
#         pic_url: "a1 PicUrl",
#         url: "a1 Url",
#       ]

#       a2 = [
#         title: "a2 Title",
#         description: "a2 Description",
#         pic_url: "a2 PicUrl",
#         url: "a2 Url",
#       ]

#       msg =
#         bare_reply()
#         |> Message.msg_type("article")
#         |> Message.article(a1)
#         |> Message.article(a2)

#       assert msg[:article_count] == 2
#       assert length(msg[:articles]) == 2

#       a1_map = Enum.into(a1, %{})
#       a2_map = Enum.into(a2, %{})

#       {a1, rest} = Keyword.pop_first(msg[:articles], :item)
#       assert a1 == a1_map
#       {a2, _} = Keyword.pop_first(rest, :item)
#       assert a2 == a2_map
#     end
#   end

#   describe "use mod" do
#     defmodule Builder do
#       import Wechat.Message

#       def message do
#         msg =
#           %{
#             to_user_name:   "toUser",
#             from_user_name: "fromUser",
#             create_time:    1348831860,
#           }
#           |> msg_type("text")
#           |> content("hello world")
#       end
#     end

#     test "inject method" do
#       message = Builder.message()

#       assert message[:content] == "hello world"
#       assert message[:msg_type] == "text"
#     end
#   end

#   defp bare_reply do
#     %{
#       to_user_name:   "toUser",
#       from_user_name: "fromUser",
#       create_time:    1348831860,
#     }
#   end
# end
