# frozen_string_literal: true

require 'rails_helper'

include WebMock::API

describe Feeds::Fetcher, type: :model do
  describe '.fetch' do
    FETCH_CASSETTE_PREFIX = 'models/feeds/fetch_response_'

    context 'URLが正しい場合' do
      let(:url) do
        'http://cyber.harvard.edu/rss/examples/rss2sample.xml'
      end

      shared_examples '結果を取得して返す' do
        it 'Etagを取得して返すこと' do
          expect(actual[:etag]).to eq '"d46a5b-9e0-42d731ba304c0"'
        end

        it 'レスポンスボディを取得して返すこと' do
          expect(actual[:body]).to match %r{<title>Liftoff News</title>}
        end
      end

      context 'Etagが未指定の場合' do
        let(:actual) do
          VCR.use_cassette "#{FETCH_CASSETTE_PREFIX}no_etag" do
            Feeds::Fetcher.fetch url
          end
        end
        it_behaves_like '結果を取得して返す'
      end

      context 'Etagが無効な場合' do
        let(:actual) do
          VCR.use_cassette "#{FETCH_CASSETTE_PREFIX}outdated_etag" do
            Feeds::Fetcher.fetch url, etag: 'OutdatedEtag'
          end
        end
        it_behaves_like '結果を取得して返す'
      end

      context 'Etagが有効な場合' do
        let(:actual) do
          VCR.use_cassette "#{FETCH_CASSETTE_PREFIX}etag" do
            Feeds::Fetcher.fetch url,
                                 etag: '"d46a5b-9e0-42d731ba304c0"',
                                 response_body_if_not_modified: 'DefaultBody'
          end
        end

        it '呼び出し時で指定した値をEtagとして返すこと' do
          expect(actual[:etag]).to eq '"d46a5b-9e0-42d731ba304c0"'
        end

        it '呼び出し時で指定した値をレスポンスボディとして返すこと' do
          expect(actual[:body]).to eq 'DefaultBody'
        end
      end
    end

    context 'URLが不正な場合' do
      shared_examples 'nilを返す' do
        let (:actual) do
          VCR.turned_off do
            Feeds::Fetcher.fetch invalid_url
          end
        end

        it 'Etagはnilを返すこと' do
          expect(actual[:etag]).to be_nil
        end

        it 'レスポンスボディはnilを返すこと' do
          expect(actual[:body]).to be_nil
        end
      end

      context 'フォーマット不正のURLの場合' do
        let(:invalid_url) do
          'invalid_url'
        end

        it_behaves_like 'nilを返す'
      end

      context '存在しないURLの場合' do
        let(:invalid_url) do
          'http://localhost/unknown'
        end

        before :all do
          stub_request(:get, 'http://localhost/unknown').to_return(
              status: 404,
          )
        end

        it_behaves_like 'nilを返す'
      end
    end
  end

  describe '.discover' do
    DISCOVER_CASSETTE_PREFIX = 'models/feeds/discover_response_'

    context 'URLが正しい場合' do
      let :actual do
        VCR.use_cassette "#{DISCOVER_CASSETTE_PREFIX}normal" do
          Feeds::Fetcher.discover('http://weblog.rubyonrails.org/')
        end
      end
      it 'フィードのタイトルを返すこと' do
        expect(actual.first[:title]).to eq 'Riding Rails'
      end
      it 'フィードのURLを返すこと' do
        expect(actual.first[:url]).to eq 'http://weblog.rubyonrails.org/feed/atom.xml'
      end
      it 'フィードのコンテンツタイプを返すこと' do
        expect(actual.first[:content_type]).to eq 'application/atom+xml'
      end
    end

    context 'URLが不正な場合' do
      it '空配列を返すこと'
    end
  end
end
