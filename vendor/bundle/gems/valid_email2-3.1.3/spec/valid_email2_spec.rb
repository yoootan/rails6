# frozen_string_literal: true

require "spec_helper"

class TestUser < TestModel
  validates :email, 'valid_email_2/email': true
end

class TestUserSubaddressing < TestModel
  validates :email, 'valid_email_2/email': { disallow_subaddressing: true }
end

class TestUserMX < TestModel
  validates :email, 'valid_email_2/email': { mx: true }
end

class TestUserDisallowDisposable < TestModel
  validates :email, 'valid_email_2/email': { disposable: true }
end

class TestUserDisallowDisposableDomain < TestModel
  validates :email, 'valid_email_2/email': { disposable_domain: true }
end

class TestUserDisallowDisposableWithWhitelist < TestModel
  validates :email, 'valid_email_2/email': { disposable_with_whitelist: true }
end

class TestUserDisallowBlacklisted < TestModel
  validates :email, 'valid_email_2/email': { blacklist: true }
end

class TestUserMessage < TestModel
  validates :email, 'valid_email_2/email': { message: "custom message" }
end

describe ValidEmail2 do

  let(:disposable_domain) { ValidEmail2.disposable_emails.first }

  describe "basic validation" do
    subject(:user) { TestUser.new(email: "") }

    it "is valid" do
      user = TestUser.new(email: "foo@bar123.com")
      expect(user.valid?).to be_truthy
    end

    it "is invalid if email is empty" do
      expect(user.valid?).to be_truthy
    end

    it "is invalid if domain is missing" do
      user = TestUser.new(email: "foo@.com")
      expect(user.valid?).to be_falsey
    end

    it "is invalid if email contains invalid characters" do
      %w[+ _ !].each do |invalid_character|
        user = TestUser.new(email: "foo@google#{invalid_character}yahoo.com")
        expect(user.valid?).to be_falsey
      end
    end

    it "is invalid if address is malformed" do
      user = TestUser.new(email: "foo@bar")
      expect(user.valid?).to be_falsey
    end

    it "is invalid if Mail::AddressListsParser raises exception" do
      user = TestUser.new(email: "foo@gmail.com")
      expect(Mail::Address).to receive(:new).and_raise(Mail::Field::ParseError.new(nil, nil, nil))
      expect(user.valid?).to be_falsey
    end

    it "is invalid if the domain contains consecutive dots" do
      user = TestUser.new(email: "foo@bar..com")
      expect(user.valid?).to be_falsey
    end

    it "is invalid if the domain contains emoticons" do
      user = TestUser.new(email: "foo🙈@gmail.com")
      expect(user.valid?).to be_falsy
    end

    it "is invalid if the domain contains .@ consecutively" do
      user = TestUser.new(email: "foo.@gmail.com")
      expect(user.valid?).to be_falsy
    end

    it "is invalid if the domain contains spaces" do
      user = TestUser.new(email: "user@gmail .com")
      expect(user.valid?).to be_falsy
    end

    it "is invalid if the domain contains a forward slash" do
      user = TestUser.new(email: "user@gm/ail.com")
      expect(user.valid?).to be_falsy
    end

    it "is invalid if the domain begins with a dash" do
      user = TestUser.new(email: "foo@-gmail.com")
      expect(user.valid?).to be_falsy
    end

    it "is invalid if the domain name ends with a dash" do
      user = TestUser.new(email: "foo@gmail-.com")
      expect(user.valid?).to be_falsy
    end
  end

  describe "with disposable validation" do
    it "is valid if it's not a disposable email" do
      user = TestUserDisallowDisposable.new(email: "foo@gmail.com")
      expect(user.valid?).to be_truthy
    end

    it "is valid if it just ends with a disposable domain" do
      user = TestUserDisallowDisposable.new(email: "foo@nondisposable-0-mail.com")
      expect(user.valid?).to be_truthy
    end

    context "with disposable domain" do
      it "is invalid with disposable domain" do
        user = TestUserDisallowDisposable.new(email: "foo@#{disposable_domain}")
        expect(user.valid?).to be_falsey
      end

      it "is invalid with disposable domain even without mx server check" do
        user = TestUserDisallowDisposableDomain.new(email: "foo@#{disposable_domain}")
        expect(user.valid?).to be_falsey
      end

      it "is invalid if the domain is a subdomain of a disposable domain" do
        user = TestUserDisallowDisposable.new(email: "foo@bar.#{disposable_domain}")
        expect(user.valid?).to be_falsey
      end

      it "allows example.com" do
        user = TestUserDisallowDisposable.new(email: "foo@example.com")
        expect(user.valid?).to be_truthy
      end
    end

    context "with domain that is not disposable but it's mx server is disposable" do
      let(:domain) { "sogetthis.com" }

      around do |example|
        ValidEmail2.disposable_emails.delete(domain)
        example.run
        ValidEmail2.disposable_emails << domain
      end

      it "is invalid" do
        user = TestUserDisallowDisposable.new(email: "foo@sogetthis.com")
        expect(user.valid?).to be_falsey
      end
    end

    describe "with whitelisted emails" do
      let(:whitelist_domain) { disposable_domain }
      let(:whitelist_file_path) { "config/whitelisted_email_domains.yml" }

      after do
        FileUtils.rm(whitelist_file_path, force: true)
      end

      it "is invalid if the domain is disposable and not in the whitelist" do
        user = TestUserDisallowDisposableWithWhitelist.new(email: "foo@#{whitelist_domain}")
        expect(user.valid?).to be_falsey
      end

      it "is valid if the domain is disposable but in the whitelist" do
        File.open(whitelist_file_path, "w") { |f| f.write [whitelist_domain].to_yaml }
        user = TestUserDisallowDisposableWithWhitelist.new(email: "foo@#{whitelist_domain}")
        expect(user.valid?).to be_falsey
      end
    end
  end

  describe "with blacklist validation" do
    it "is valid if the domain is not blacklisted" do
      user = TestUserDisallowBlacklisted.new(email: "foo@gmail.com")
      expect(user.valid?).to be_truthy
    end

    it "is invalid if the domain is blacklisted" do
      user = TestUserDisallowBlacklisted.new(email: "foo@#{ValidEmail2.blacklist.first}")
      expect(user.valid?).to be_falsey
    end
  end

  describe "with mx validation" do
    it "is valid if mx records are found" do
      user = TestUserMX.new(email: "foo@gmail.com")
      expect(user.valid?).to be_truthy
    end

    it "is valid if A records are found" do
      user = TestUserMX.new(email: "foo@ghs.google.com")
      expect(user.valid?).to be_truthy
    end

    it "is invalid if no mx records are found" do
      user = TestUserMX.new(email: "foo@subdomain.gmail.com")
      expect(user.valid?).to be_falsey
    end
  end

  describe "with subaddress validation" do
    it "is valid when address does not contain subaddress" do
      user = TestUserSubaddressing.new(email: "foo@gmail.com")
      expect(user.valid?).to be_truthy
    end

    it "is invalid when address cotains subaddress" do
      user = TestUserSubaddressing.new(email: "foo+1@gmail.com")
      expect(user.valid?).to be_falsey
    end
  end

  describe "with custom error message" do
    it "supports settings a custom error message" do
      user = TestUserMessage.new(email: "fakeemail")
      user.valid?
      expect(user.errors.full_messages).to include("Email custom message")
    end
  end

  describe "#subaddressed?" do
    it "is true when address local part contains a recipient delimiter ('+')" do
      email = ValidEmail2::Address.new("foo+1@gmail.com")
      expect(email.subaddressed?).to be_truthy
    end

    it "is false when address local part contains a recipient delimiter ('+')" do
      email = ValidEmail2::Address.new("foo@gmail.com")
      expect(email.subaddressed?).to be_falsey
    end
  end
end
