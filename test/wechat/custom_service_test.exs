defmodule Wechat.CustomServiceTest do
  use ExUnit.Case

  alias Wechat.CustomService

  @tag pending: true
  test "#get_kf_list" do
    result = CustomService.get_kf_list()

    assert result["kf_list"]
  end

  @tag pending: true
  test "#get_online_kf_list" do
    result = CustomService.get_online_kf_list()

    assert result["kf_online_list"]
  end

  @tag pending: true
  test "#add_account" do
    result = CustomService.add_account("test@example", "kf no1")

    assert result["errcode"] == 0
    assert result["errmsg"] == "ok"
  end

  @tag pending: true
  test "#invite_worker" do
    result = CustomService.invite_worker("test1@test", "wx_account_number")

    assert result["errcode"] == 0
    assert result["errmsg"] == "ok"
  end

  @tag pending: true
  test "#update_account" do
    result = CustomService.update_account("test@example", "kf no2")

    assert result["errcode"] == 0
    assert result["errmsg"] == "ok"
  end

  @tag pending: true
  test "#update_head_img" do
    file = "../../fixture/media_assets/elixir.png" |> Path.expand(__DIR__)
    result = CustomService.upload_head_img("test@example", file)

    assert result["errcode"] == 0
    assert result["errmsg"] == "ok"
  end

  @tag pending: true
  test "#delete_account" do
    result = CustomService.delete_account("test@example")

    assert result["errcode"] == 0
    assert result["errmsg"] == "ok"
  end

  @tag pending: true
  test "#create_session" do
    result = CustomService.create_session("test@example", "open_id")

    assert result["errcode"] == 0
    assert result["errmsg"] == "ok"
  end

  @tag pending: true
  test "#close_session" do
    result = CustomService.close_session("test@example", "open_id")

    assert result["errcode"] == 0
    assert result["errmsg"] == "ok"
  end

  @tag pending: true
  test "#get_session" do
    open_id = "open_id"
    result = CustomService.get_session(open_id)

    assert result["createtime"]
    assert result["kf_account"]
  end

  @tag pending: true
  test "#get_session_list" do
    kf_account = "kf_account"
    result = CustomService.get_session_list(kf_account)

    assert result["sessionlist"] |> is_list
  end

  @tag pending: true
  test "#get_wait_case" do
    result = CustomService.get_wait_case()

    assert result["count"] |> is_integer
    assert result["waitcaselist"] |> is_list
  end

  @tag pending: true
  test "#get_message_list" do
    result = CustomService.get_message_list(987654321, 987654321)

    assert result["number"] |> is_integer
    assert result["recordlist"] |> is_list
    assert result["msgid"]
  end
end
