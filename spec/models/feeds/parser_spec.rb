require "rails_helper"

RSpec.describe Feeds::Parser, type: :model do
  describe "parse_content!" do
    let(:parser) { Feeds::Parser.new }

    context "RSS1.0形式の場合" do
      it "フィードをパースし、チャンネル情報と記事を返すこと" do
        result = parser.parse_content!(RSS1_0_FEED_CONTENT)

        expect(result[:channel_title]).to eq "XML.com"
        expect(result[:channel_url]).to eq "http://xml.com/pub"
        expect(result[:channel_description]).to eq "XML.com..."
        expect(result[:articles].size).to eq 0 # 発行日のないitemは無視するため0
      end
    end

    context "RSS2.0形式の場合" do
      it "フィードをパースし、チャンネル情報と記事を取得すること" do
        result = parser.parse_content!(RSS2_0_FEED_CONTENT)

        expect(result[:channel_title]).to eq "Liftoff News"
        expect(result[:channel_url]).to eq "http://liftoff.msfc.nasa.gov/"
        expect(result[:channel_description]).to eq "Liftoff to Space Exploration."
        expect(result[:articles].size).to eq 1
      end
    end

    context "Atom形式の場合" do
      it "フィードをパースし、チャンネル情報と記事を取得すること" do
        result = parser.parse_content!(ATOM_FEED_CONTENT)

        expect(result[:channel_title]).to eq "Example Feed"
        expect(result[:channel_url]).to eq "http://example.org/"
        expect(result[:channel_description]).to be_nil
        expect(result[:articles].size).to eq 1
      end
    end

    context "未知の形式の場合" do
      it "例外をスローすること" do
        expect { parser.parse_content!("<aaa></aaa>") }.to raise_error(Feed::FeedError)
      end
    end
  end

  # https://www.futomi.com/lecture/japanese/rss10.html
  RSS1_0_FEED_CONTENT = <<~XML.freeze
    <?xml version="1.0"?>
    <rdf:RDF
      xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns="http://purl.org/rss/1.0/"
      >
      <channel rdf:about="http://www.xml.com/xml/news.rss">
        <title>XML.com</title>
        <link>http://xml.com/pub</link>
        <description>XML.com...</description>
        <image rdf:resource="http://xml.com/universal/images/xml_tiny.gif" />
        <items>
          <rdf:Seq>
            <rdf:li resource="http://xml.com/pub/2000/08/09/xslt/xslt.html" />
            <rdf:li resource="http://xml.com/pub/2000/08/09/rdfdb/index.html" />
          </rdf:Seq>
        </items>
      </channel>
      <image rdf:about="http://xml.com/universal/images/xml_tiny.gif">
        <title>XML.com</title>
        <link>http://www.xml.com</link>
        <url>http://xml.com/universal/images/xml_tiny.gif</url>
      </image>
      <item rdf:about="http://xml.com/pub/2000/08/09/xslt/xslt.html">
        <title>Processing Inclusions with XSLT</title>
        <link>http://xml.com/pub/2000/08/09/xslt/xslt.html</link>
        <description>Processing document...</description>
      </item>
    </rdf:RDF>
  XML

  # https://www.futomi.com/lecture/japanese/rss20.html#sampleFiles
  RSS2_0_FEED_CONTENT = <<~XML.freeze
    <rss version="2.0">
      <channel>
        <title>Liftoff News</title>
        <link>http://liftoff.msfc.nasa.gov/</link>
        <description>Liftoff to Space Exploration.</description>
        <language>en-us</language>
        <pubDate>Tue, 10 Jun 2003 04:00:00 GMT</pubDate>
        <lastBuildDate>Tue, 10 Jun 2003 09:41:01 GMT</lastBuildDate>
        <docs>http://blogs.law.harvard.edu/tech/rss</docs>
        <generator>Weblog Editor 2.0</generator>
        <managingEditor>editor@example.com</managingEditor>
        <webMaster>webmaster@example.com</webMaster>
        <item>
          <title>Star City</title>
          <link>http://liftoff.msfc.nasa.gov/news/2003/news-starcity.asp</link>
          <description>How do Americans...</description>
          <pubDate>Tue, 03 Jun 2003 09:39:21 GMT</pubDate>
          <guid>http://liftoff.msfc.nasa.gov/2003/06/03.html#item573</guid>
        </item>
      </channel>
    </rss>
  XML

  # https://validator.w3.org/feed/docs/atom.html#sampleFeed
  ATOM_FEED_CONTENT = <<~XML.freeze
    <?xml version="1.0" encoding="utf-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom">
      <title>Example Feed</title>
      <link href="http://example.org/"/>
      <updated>2003-12-13T18:30:02Z</updated>
      <author>
        <name>John Doe</name>
      </author>
      <id>urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6</id>
      <entry>
        <title>Atom-Powered Robots Run Amok</title>
        <link href="http://example.org/2003/12/13/atom03"/>
        <id>urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a</id>
        <updated>2003-12-13T18:30:02Z</updated>
        <summary>Some text.</summary>
      </entry>
    </feed>
  XML
end
