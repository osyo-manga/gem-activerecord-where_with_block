# frozen_string_literal: true

RSpec.describe Activerecord::WhereWithBlock do
  describe "#==" do
    subject { User.where(&body).to_sql }

    context "left to symbol" do
      let(:body) { -> { :name == "homu" } }
      it { is_expected.to match /WHERE "users"."name" = 'homu'/ }
    end

    context "right to symbol" do
      let(:body) { -> { "homu" == :name } }
      it { is_expected.to match /WHERE "users"."name" = 'homu'/ }
    end

    context "left and right to symbol" do
      let(:body) { -> { :name == :homu } }
      it { is_expected.to match /WHERE "users"."name" = "users"."homu"/ }
    end
  end

  describe "#!=" do
    subject { User.where(&body).to_sql }

    context "left to symbol" do
      let(:body) { -> { :name != "homu" } }
      it { is_expected.to match /WHERE "users"."name" != 'homu'/ }
    end

    context "right to symbol" do
      let(:body) { -> { "homu" != :name } }
      it { is_expected.to match /WHERE "users"."name" != 'homu'/ }
    end

    context "left and right to symbol" do
      let(:body) { -> { :name != :homu } }
      it { is_expected.to match /WHERE "users"."name" != "users"."homu"/ }
    end
  end

  describe "#=~" do
    subject { User.where(&body).to_sql }

    context "left to symbol" do
      let(:body) { -> { :name =~ "homu" } }
      it { is_expected.to match /WHERE "users"."name" LIKE 'homu'/ }
    end

    context "right to symbol" do
      let(:body) { -> { "homu" =~ :name } }
      it { is_expected.to match /WHERE "users"."name" LIKE 'homu'/ }
    end

    context "left and right to symbol" do
      let(:body) { -> { :name =~ :homu } }
      it { is_expected.to match /WHERE "users"."name" LIKE "users"."homu"/ }
    end
  end

  describe "#>" do
    subject { User.where(&body).to_sql }

    context "left to symbol" do
      let(:body) { -> { :name > "homu" } }
      it { is_expected.to match /WHERE "users"."name" > 'homu'/ }
    end

    context "right to symbol" do
      let(:body) { -> { "homu" > :name } }
      it { is_expected.to match /WHERE "users"."name" < 'homu'/ }
    end

    context "left and right to symbol" do
      let(:body) { -> { :name > :homu } }
      it { is_expected.to match /WHERE "users"."name" > "users"."homu"/ }
    end
  end

  describe "#>=" do
    subject { User.where(&body).to_sql }

    context "left to symbol" do
      let(:body) { -> { :name >= "homu" } }
      it { is_expected.to match /WHERE "users"."name" >= 'homu'/ }
    end

    context "right to symbol" do
      let(:body) { -> { "homu" >= :name } }
      it { is_expected.to match /WHERE "users"."name" <= 'homu'/ }
    end

    context "left and right to symbol" do
      let(:body) { -> { :name >= :homu } }
      it { is_expected.to match /WHERE "users"."name" >= "users"."homu"/ }
    end
  end

  describe "#<" do
    subject { User.where(&body).to_sql }

    context "left to symbol" do
      let(:body) { -> { :name < "homu" } }
      it { is_expected.to match /WHERE "users"."name" < 'homu'/ }
    end

    context "right to symbol" do
      let(:body) { -> { "homu" < :name } }
      it { is_expected.to match /WHERE "users"."name" > 'homu'/ }
    end

    context "left and right to symbol" do
      let(:body) { -> { :name < :homu } }
      it { is_expected.to match /WHERE "users"."name" < "users"."homu"/ }
    end
  end

  describe "#<=" do
    subject { User.where(&body).to_sql }

    context "left to symbol" do
      let(:body) { -> { :name <= "homu" } }
      it { is_expected.to match /WHERE "users"."name" <= 'homu'/ }
    end

    context "right to symbol" do
      let(:body) { -> { "homu" <= :name } }
      it { is_expected.to match /WHERE "users"."name" >= 'homu'/ }
    end

    context "left and right to symbol" do
      let(:body) { -> { :name <= :homu } }
      it { is_expected.to match /WHERE "users"."name" <= "users"."homu"/ }
    end
  end

  describe "&&" do
    subject { User.where(&body).to_sql }

    let(:body) { -> { :name == "homu" && :age < 20 } }
    it { is_expected.to match /WHERE "users"."name" = 'homu' AND "users"."age" < 20/ }
  end

  describe "||" do
    subject { User.where(&body).to_sql }

    let(:body) { -> { :name == "homu" || :age < 20 } }
    it { is_expected.to match /WHERE \("users"."name" = 'homu' OR "users"."age" < 20\)/ }
  end

  describe "capture variable" do
    subject { User.where(&body).to_sql }

    let(:body) {
      name = "homu"
      age = 20
      -> { :name == name && :age < age }
    }
    it { is_expected.to match /WHERE "users"."name" = 'homu' AND "users"."age" < 20/ }
  end

  describe "capture method" do
    let(:name) { "homu" }
    let(:age) { 20 }
    subject { User.where(&body).to_sql }

    let(:body) { -> { :name == name && :age < age } }
    it { is_expected.to match /WHERE "users"."name" = 'homu' AND "users"."age" < 20/ }
  end

  describe "call Symbol methods" do
    let(:body) { -> { :name == :homu.to_s } }
    subject { User.where(&body).to_sql }
    it { is_expected.to match /WHERE "users"."name" = 'homu'/ }
  end

  describe "JOIN" do
    context "has_one" do
    let(:body) { -> { :comments.text == "OK" && :name == "homu" } }
      subject { User.joins(:comments).where(&body).to_sql }
      it { is_expected.to match /WHERE "comments"."text" = 'OK' AND "users"."name" = 'homu'/ }
      it do
        puts subject
        puts User.joins(:comments).where(comments: { text: "OK" }).to_sql
      end
    end
  end

  describe "original where" do
    subject { User.where("name == ? AND age < ?", "homu", 14).to_sql }
    it { is_expected.to match /WHERE \(name == 'homu' AND age < 14\)/ }
  end
end
