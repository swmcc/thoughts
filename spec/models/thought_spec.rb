require "rails_helper"

RSpec.describe Thought, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      thought = build(:thought)
      expect(thought).to be_valid
    end

    it "requires content to be present" do
      thought = build(:thought, content: nil)
      expect(thought).not_to be_valid
      expect(thought.errors[:content]).to include("can't be blank")
    end

    it "requires content to be at most 140 characters" do
      thought = build(:thought, content: "A" * 141)
      expect(thought).not_to be_valid
      expect(thought.errors[:content]).to include("is too long (maximum is 140 characters)")
    end

    it "allows content of exactly 140 characters" do
      thought = build(:thought, content: "A" * 140)
      expect(thought).to be_valid
    end

    it "requires view_count to be a non-negative integer" do
      thought = build(:thought, view_count: -1)
      expect(thought).not_to be_valid
    end
  end

  describe "tags normalization" do
    it "normalizes tags to lowercase" do
      thought = create(:thought, tags: [ "Rails", "RUBY" ])
      expect(thought.tags).to eq([ "rails", "ruby" ])
    end

    it "strips whitespace from tags" do
      thought = create(:thought, tags: [ " rails ", "  ruby  " ])
      expect(thought.tags).to eq([ "rails", "ruby" ])
    end

    it "removes duplicate tags" do
      thought = create(:thought, tags: [ "rails", "Rails", "RAILS" ])
      expect(thought.tags).to eq([ "rails" ])
    end

    it "removes blank tags" do
      thought = create(:thought, tags: [ "rails", "", "  ", "ruby" ])
      expect(thought.tags).to eq([ "rails", "ruby" ])
    end
  end

  describe "scopes" do
    describe ".recent" do
      it "orders thoughts by created_at descending" do
        old_thought = create(:thought, created_at: 1.day.ago)
        new_thought = create(:thought, created_at: 1.hour.ago)

        expect(Thought.recent).to eq([ new_thought, old_thought ])
      end
    end

    describe ".with_tag" do
      it "filters thoughts by tag" do
        rails_thought = create(:thought, tags: [ "rails" ])
        ruby_thought = create(:thought, tags: [ "ruby" ])
        both_thought = create(:thought, tags: [ "rails", "ruby" ])

        expect(Thought.with_tag("rails")).to contain_exactly(rails_thought, both_thought)
      end
    end
  end

  describe "#increment_view_count!" do
    it "increments the view count by 1" do
      thought = create(:thought, view_count: 5)
      thought.increment_view_count!
      expect(thought.reload.view_count).to eq(6)
    end
  end
end
