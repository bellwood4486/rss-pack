# frozen_string_literal: true

require 'rails_helper'

describe Feeds::Fetcher, type: :model do
  describe '.fetch' do
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
          Feeds::Fetcher.fetch url
        end
        it_behaves_like '結果を取得して返す'
      end

      context 'Etagが無効な場合' do
        let(:actual) do
          Feeds::Fetcher.fetch url, etag: 'OutdatedEtag'
        end
        it_behaves_like '結果を取得して返す'
      end

      context 'Etagが有効な場合' do
        it '呼び出し時で指定した値をレスポンスボディとして返すこと' do
          actual = Feeds::Fetcher.fetch url,
                                        etag: '"d46a5b-9e0-42d731ba304c0"',
                                        response_body_if_not_modified: 'DefaultBody'
          expect(actual[:body]).to eq 'DefaultBody'
        end
      end
    end
  end

end
