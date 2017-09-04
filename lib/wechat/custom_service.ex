defmodule Wechat.CustomService do
  @moduledoc """
  Custom Service Api
  ref: https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1458557405
  """

  use Wechat.HTTP, host: "https://api.weixin.qq.com/customservice/"

  alias Wechat.API

  def get_kf_list do
    API.get("/customservice/getkflist")
  end

  def get_online_kf_list do
    API.get("/customservice/getonlinekflist")
  end

  def add_account(account, nickname) do
    post("/kfaccount/add", %{
      kf_account: account,
      nickname: nickname
    })
  end

  def invite_worker(kf_account, wx_account) do
    post("/kfaccount/inviteworker", %{
      kf_account: kf_account,
      invite_wx: wx_account
    })
  end

  def update_account(account, nickname) do
    post("/kfaccount/update", %{
      kf_account: account,
      nickname: nickname
    })
  end

  def delete_account(kf_account) do
    get("/kfaccount/del", %{kf_account: kf_account})
  end

  def upload_head_img(kf_account, file) do
    post("/kfaccount/uploadheadimg", {:multipart, [{:file, file}]}, %{kf_account: kf_account})
  end

  # session management
  def get_session(open_id) do
    get("/kfsession/getsession", %{open_id: open_id})
  end

  def get_session_list(kf_account) do
    get("/kfsession/getsessionlist", %{kf_account: kf_account})
  end

  def get_wait_case do
    get("/kfsession/getwaitcase")
  end

  session_mapping = %{
    create_session: "/kfsession/create",
    close_session: "/kfsession/close"
  }
  for {fun, url} <- session_mapping do
    def unquote(fun)(kf_account, open_id) do
      post(unquote(url), %{
        kf_account: kf_account,
        openid: open_id
      })
    end
  end

  # message list

  def get_message_list(starttime, endtime, msgid \\ 1, number \\ 10_000) do
    post("/msgrecord/getmsglist", %{
      starttime: starttime,
      endtime:   endtime,
      msgid:     msgid,
      number:    number,
    })
  end
end
