require "rails_helper"

RSpec.describe "Api::V1::Current::Articles", type: :request do
  describe "GET /api/v1/current/articles" do
    subject { get(api_v1_current_articles_path, headers:) }

    let(:headers) { current_user.create_new_auth_token }
    let(:current_user) { create(:user) }
    let(:other_user) { create(:user) }

    before { create_list(:article, 2, user: other_user) }

    context "ログインユーザーに紐づくarticlesレコードが存在する時" do
      before { create_list(:article, 3, user: current_user) }

      it "正常にレコードを取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(res[0].keys).to eq ["id", "title", "content", "status", "created_at", "from_today", "user"]
        expect(res[0]["user"].keys).to eq ["name"]
        expect(res.length).to eq(3)
        expect(response).to have_http_status(:ok)
      end
    end

    context "ログインユーザーに紐づくarticlesレコードが存在しない時" do
      it "レコードが取得できない" do
        subject
        res = JSON.parse(response.body)
        expect(res.length).to eq(0)
        expect(response).to have_http_status(:ok)
      end
    end


  end

  describe "GET /api/v1/current/articles/:id" do
    subject { get(api_v1_current_article_path(id), headers:) }

    let(:headers) { current_user.create_new_auth_token }
    let(:current_user) { create(:user) }

    context ":id がログインユーザーに紐づく articles レコードの id である時" do
      let(:current_user_article) { create(:article, user: current_user) }
      let(:id) { current_user_article.id }

      it "正常にレコードが取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(res.keys).to eq ["id", "title", "content", "status", "created_at", "from_today", "user"]
        expect(res["user"].keys).to eq ["name"]
        expect(response).to have_http_status(:ok)
      end
    end

    context ":id がログインユーザーに紐づく articles レコードの id ではない時" do
      let(:other_user) { create(:user) }
      let(:other_user_article) { create(:article, user: other_user) }
      let(:id) { other_user_article.id }

      it "404エラーが返る" do
        subject
        expect(response).to have_http_status(404)
      end

    end

  end


  describe "POST /api/v1/current/articles" do
    subject { post(api_v1_current_articles_path, headers:) }

    let(:headers) { current_user.create_new_auth_token }
    let(:current_user) { create(:user) }

    context "ログインユーザーに紐づく未保存ステータスの記事が0件の時" do
      it "ステータスが未保存の記事が作成される" do
        expect { subject }.to change { current_user.articles.count }.by(1)
        expect(current_user.articles.last).to be_unsaved
        res = JSON.parse(response.body)
        expect(res.keys).to eq ["id", "title", "content", "status", "created_at", "from_today", "user"]
        expect(res["user"].keys).to eq ["name"]
        expect(response).to have_http_status(:ok)
      end
    end

    context "ログインユーザーに紐づく未保存ステータスの記事が1件の時" do
      before { create(:article, user: current_user, status: :unsaved) }

      it "未保存ステータスの記事が作成されない" do
        expect { subject }.not_to change { current_user.articles.count }
        res = JSON.parse(response.body)
        expect(res.keys).to eq ["id", "title", "content", "status", "created_at", "from_today", "user"]
        expect(res["user"].keys).to eq ["name"]
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PUT /api/v1/current/articles/id" do
    subject { put(api_v1_current_article_path(id), headers:, params:) }

    let(:headers) { current_user.create_new_auth_token }
    let(:current_user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:params) { { "article": { "title": "テストタイトル2", "content": "テスト本文2", "status": "published" } } }

    context "idがログインユーザーに紐づくarticlesレコードのidである時" do
      let(:current_user_article) { create(:article, title: "テストタイトル1", content: "テスト本文1", status: :draft, user: current_user) }
      let(:id) { current_user_article.id }

      it "正常にレコードを保存できる" do
        expect { subject }.to change { current_user_article.reload.title }.from("テストタイトル1").to("テストタイトル2") and
          change { current_user_article.reload.content }.from("テスト本文1").to("テスト本文2") and
          change { current_user_article.reload.status }.from("draft").to("published")
        res = JSON.parse(response.body)
        expect(res.keys).to eq ["id", "title", "content", "status", "created_at", "from_today", "user"]
        expect(res["user"].keys).to eq ["name"]
        expect(response).to have_http_status(:ok)
      end
    end

    context "idがログインユーザーに紐づくarticlesレコードのidでない時" do
      let(:other_user_article) { create(:article, user: other_user) }
      let(:id) { other_user_article.id }

      it "404エラーが返る" do
        subject
        expect(response).to have_http_status(404)
      end
    end
  end
end
