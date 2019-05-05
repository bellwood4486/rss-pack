require "rails_helper"

RSpec.describe Pack, type: :model do
  describe "rss_url" do
    it "トークンを含むURLを返すこと" do
      pack = create(:pack)
      expect(pack.rss_url).to include pack.token
    end
  end

  describe "reload_rss!" do
    let(:pack) { create(:pack, rss_created_at: nil) }

    let(:subscription_mocks) do
      mocks = []
      # 以下のケースにおいてRubyMine(2018.3.5)のブレイクポイントが止まらない事象が発生するため、その回避コード
      # - receive_message_chainメソッドを使う
      # - receiveメソッドを使い、かつand_returnメソッドにdoubleオブジェクトを渡す
      def mocks.includes(*_symbols)
      end
      allow(mocks).to receive(:includes).and_return(mocks)

      mocks
    end

    let(:rss_xml_namespaces) do
      {
        xmlns: "http://www.w3.org/2005/Atom",
        dc: "http://purl.org/dc/elements/1.1/",
      }
    end

    it "紐づく全Subscriptionの未読記事を含むRSSコンテンツを作成すること" do
      subscription_mocks << instance_double("Subscription",
                                            unread_articles: [
                                              article_mock(title: "1a"),
                                              article_mock(title: "1b"),
                                            ])
      subscription_mocks << instance_double("Subscription",
                                            unread_articles: [
                                              article_mock(title: "2a"),
                                              article_mock(title: "2b"),
                                            ])
      allow(pack).to receive(:subscriptions).and_return(subscription_mocks)

      pack.reload_rss!

      doc = ::Nokogiri::XML(pack.rss_content)
      expect(doc.xpath("//xmlns:entry", rss_xml_namespaces).count).to eq 4
      expect(doc.xpath("//xmlns:entry/xmlns:title[.='1a']", rss_xml_namespaces).count).to eq 1
      expect(doc.xpath("//xmlns:entry/xmlns:title[.='1b']", rss_xml_namespaces).count).to eq 1
      expect(doc.xpath("//xmlns:entry/xmlns:title[.='2a']", rss_xml_namespaces).count).to eq 1
      expect(doc.xpath("//xmlns:entry/xmlns:title[.='2b']", rss_xml_namespaces).count).to eq 1
    end

    it "RSSコンテンツにはチャネルに関する要素を含むこと" do
      allow(pack).to receive(:subscriptions).and_return(subscription_mocks)

      pack.reload_rss!

      doc = ::Nokogiri::XML(pack.rss_content)
      expect(doc.xpath("//xmlns:author", rss_xml_namespaces).count).to eq 1
      expect(doc.xpath("//xmlns:link", rss_xml_namespaces).count).to eq 1
      expect(doc.xpath("//xmlns:title", rss_xml_namespaces).count).to eq 1
      expect(doc.xpath("//xmlns:subtitle", rss_xml_namespaces).count).to eq 1
      expect(doc.xpath("//xmlns:updated", rss_xml_namespaces).count).to eq 1
    end

    it "RSSコンテンツには記事に関する要素を含むこと" do
      subscription_mocks << instance_double("Subscription",
                                            unread_articles: [
                                              article_mock(title: "1a"),
                                            ])
      allow(pack).to receive(:subscriptions).and_return(subscription_mocks)

      pack.reload_rss!

      doc = ::Nokogiri::XML(pack.rss_content)
      expect(doc.xpath("//xmlns:entry/xmlns:title", rss_xml_namespaces).count).to eq 1
      expect(doc.xpath("//xmlns:entry/xmlns:link", rss_xml_namespaces).count).to eq 1
      expect(doc.xpath("//xmlns:entry/xmlns:summary", rss_xml_namespaces).count).to eq 1
      expect(doc.xpath("//xmlns:entry/xmlns:updated", rss_xml_namespaces).count).to eq 1
    end

    context "まだ一度もリロードしたことがない場合" do
      it "パックのRSSのリロードを行うこと" do
        pack = create(:pack, rss_content: nil, rss_created_at: nil)

        expect { pack.reload_rss! }.to change(pack, :rss_content)
      end
    end

    context "リロードされたことがあり、かつ、パックのリロード間隔が経過していた場合" do
      it "パックのRSSのリロードを行うこと" do
        pack = create(:pack, rss_content: nil, rss_created_at: Time.zone.now)

        stub_const("Pack::RSS_CREATE_INTERVAL", 10)
        travel_to(11.seconds.since(pack.rss_created_at)) do
          expect { pack.reload_rss! }.to change(pack, :rss_content)
        end
      end
    end

    context "リロードされたことがあり、かつ、パックのリロード間隔が経過していない場合" do
      it "パックのRSSのリロードを行わないこと" do
        pack = create(:pack, rss_content: nil, rss_created_at: Time.zone.now)

        stub_const("Pack::RSS_CREATE_INTERVAL", 10)
        travel_to(9.seconds.since(pack.rss_created_at)) do
          expect { pack.reload_rss! }.not_to change(pack, :rss_content)
        end
      end
    end
  end

  describe "next_rss_reload_time" do
    it "リロード間隔分だけ将来の時刻を返すこと" do
      stub_const("Pack::RSS_CREATE_INTERVAL", 1)
      pack = create(:pack, rss_created_at: Time.zone.parse("2019/1/1 09:00:00"))
      expect(pack.next_rss_reload_time).to eq Time.zone.parse("2019/1/1 09:00:01")
    end
  end

  def article_mock(title: "dummy_title", link: "dummy_link",
                   summary: "dummy_summary", published_at: Time.zone.now)
    instance_double("Article",
                    title: title,
                    link: link,
                    summary: summary,
                    published_at: published_at)
  end
end
