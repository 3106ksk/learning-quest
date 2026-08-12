require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      name: "Example User",
      email_address: "user@example.com",
      password: "password"
    )
  end

  test "is valid with valid attributes" do
    assert @user.valid?
  end

  test "requires a name" do
    @user.name = " "

    assert_not @user.valid?
    assert @user.errors.of_kind?(:name, :blank)
  end

  test "name must not exceed 50 characters" do
    @user.name = "a" * 51

    assert_not @user.valid?
    assert @user.errors.of_kind?(:name, :too_long)
  end

  test "requires an email_address" do
    @user.email_address = " "

    assert_not @user.valid?
    assert @user.errors.of_kind?(:email_address, :blank)
  end

  test "email_address must not exceed 255 characters" do
    @user.email_address = "#{"a" * 244}@example.com"

    assert_not @user.valid?
    assert @user.errors.of_kind?(:email_address, :too_long)
  end

  test "rejects invalid email_address formats" do
    invalid_addresses = [
      "user",
      "user@example",
      "user@ example.com",
      "user@example,com"
    ]

    invalid_addresses.each do |address|
      @user.email_address = address

      assert_not @user.valid?, "#{address.inspect} should be invalid"
      assert @user.errors.of_kind?(:email_address, :invalid)
    end
  end

  test "email_address must be unique regardless of case" do
    @user.email_address = users(:one).email_address.upcase

    assert_not @user.valid?
    assert @user.errors.of_kind?(:email_address, :taken)
  end

  test "downcases and strips email_address" do
    @user.email_address = " DOWNCASED@EXAMPLE.COM "

    assert_equal "downcased@example.com", @user.email_address
  end
end
