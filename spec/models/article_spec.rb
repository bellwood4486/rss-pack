require "rails_helper"

RSpec.describe Article, type: :model do
  it "有効なファクトリをもつこと" do
    expect(build(:article)).to be_valid
  end

  it "タイトルがなければ無効な状態とみなし例外をスローすること" do
    article = build(:article, title: nil)
    expect { article.valid? }.to raise_error(ActiveModel::StrictValidationFailed, /を入力してください/)
  end

  it "リンクがなければ無効な状態とみなし例外をスローすること" do
    article = build(:article, link: nil)
    expect { article.valid? }.to raise_error(ActiveModel::StrictValidationFailed, /を入力してください/)
  end

  describe "scope published_since" do
    it "指定した公開日時よりあとの記事のみに絞ること" do
      create(:article, published_at: Time.zone.parse("2019/1/1 00:00:00"))
      create(:article, published_at: Time.zone.parse("2019/1/2 00:00:00"))

      actual_articles = Article.published_since(Time.zone.parse("2019/1/1 00:00:00"))

      expect(actual_articles.pluck(:published_at)).to match_array [Time.zone.parse("2019/1/2 00:00:00")]
    end
  end

  describe "before_validation truncate_summary" do
    it "サマリーが最大長を超えている場合、末尾を切ること" do
      stub_const("Article::SUMMARY_MAX_LENGTH", 5)
      article = build(:article, summary: "a" * 10)
      article.valid?
      expect(article.summary.length).to eq 5
    end
  end
end
