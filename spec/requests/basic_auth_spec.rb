require 'rails_helper'

RSpec.describe "BASIC認証", type: :request do
  let(:auth_env) do
    {
      "BASIC_AUTH_ENABLED" => enabled,
      "BASIC_AUTH_USER" => "staging-user",
      "BASIC_AUTH_PASSWORD" => "staging-password"
    }
  end

  around do |example|
    original = auth_env.keys.to_h { |key| [ key, ENV[key] ] }
    auth_env.each { |key, value| ENV[key] = value }
    example.run
  ensure
    original.each { |key, value| ENV[key] = value }
  end

  def basic_auth_header(user, password)
    { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(user, password) }
  end

  context "BASIC_AUTH_ENABLED が \"true\" の場合" do
    let(:enabled) { "true" }

    it "合言葉なしでは 401 を返す" do
      get root_path

      expect(response).to have_http_status(:unauthorized)
    end

    it "合言葉が違うと 401 を返す" do
      get root_path, headers: basic_auth_header("staging-user", "wrong-password")

      expect(response).to have_http_status(:unauthorized)
    end

    it "合言葉が合っていれば LP を表示する" do
      get root_path, headers: basic_auth_header("staging-user", "staging-password")

      expect(response).to have_http_status(:ok)
    end
  end

  context "BASIC_AUTH_ENABLED が無い場合" do
    let(:enabled) { nil }

    it "合言葉なしで LP を表示する" do
      get root_path

      expect(response).to have_http_status(:ok)
    end
  end
end
