require 'rails_helper'

RSpec.describe User, type: :model do
  it "有効なユーザーを生成できる" do
    user = create(:user)

    expect(user).to be_persisted
    expect(user).to be_valid
  end
end
