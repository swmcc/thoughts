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

  describe "source" do
    it "defaults to web" do
      thought = create(:thought)
      expect(thought.source).to eq("web")
    end

    it "validates source is one of the allowed values" do
      thought = build(:thought, source: "invalid")
      expect(thought).not_to be_valid
      expect(thought.errors[:source]).to include("is not included in the list")
    end

    it "allows web as source" do
      thought = build(:thought, source: "web")
      expect(thought).to be_valid
    end

    it "allows cli as source" do
      thought = build(:thought, source: "cli")
      expect(thought).to be_valid
    end

    it "allows iphone as source" do
      thought = build(:thought, source: "iphone")
      expect(thought).to be_valid
    end
  end

  describe "#source_label" do
    it "returns 'Written from web' for web source" do
      thought = build(:thought, source: "web")
      expect(thought.source_label).to eq("Written from web")
    end

    it "returns 'Written from CLI' for cli source" do
      thought = build(:thought, source: "cli")
      expect(thought.source_label).to eq("Written from CLI")
    end

    it "returns 'Written from iPhone' for iphone source" do
      thought = build(:thought, source: "iphone")
      expect(thought.source_label).to eq("Written from iPhone")
    end
  end

  describe "threading" do
    it "defaults parent_id to nil" do
      thought = create(:thought, content: "A top level thought")
      expect(thought.parent_id).to be_nil
      expect(thought.parent).to be_nil
    end

    it "links a reply to its parent and back again" do
      parent = create(:thought, content: "Parent thought")
      reply = create(:thought, content: "Reply thought", parent: parent)

      expect(reply.parent).to eq(parent)
      expect(parent.replies).to include(reply)
    end

    it "orders replies oldest first" do
      parent = create(:thought, content: "Parent thought")
      newer = create(:thought, content: "Newer reply", parent: parent, created_at: 1.hour.ago)
      older = create(:thought, content: "Older reply", parent: parent, created_at: 1.day.ago)

      expect(parent.replies.to_a).to eq([ older, newer ])
    end

    describe ".top_level" do
      it "returns only thoughts without a parent" do
        parent = create(:thought, content: "Parent thought")
        create(:thought, content: "Reply thought", parent: parent)

        expect(Thought.top_level).to contain_exactly(parent)
      end
    end

    describe "#reply_count" do
      it "counts direct replies only" do
        parent = create(:thought, content: "Parent thought")
        reply = create(:thought, content: "First reply", parent: parent)
        create(:thought, content: "Second reply", parent: parent)
        create(:thought, content: "Nested reply", parent: reply)

        expect(parent.reply_count).to eq(2)
        expect(reply.reply_count).to eq(1)
      end

      it "is zero for a thought with no replies" do
        expect(create(:thought, content: "Lonely thought").reply_count).to eq(0)
      end
    end

    describe "#thread_root" do
      it "returns self for a top-level thought" do
        thought = create(:thought, content: "Top level thought")
        expect(thought.thread_root).to eq(thought)
      end

      it "returns the topmost ancestor from a nested reply" do
        root = create(:thought, content: "Root thought")
        reply = create(:thought, content: "Reply thought", parent: root)
        nested = create(:thought, content: "Nested reply", parent: reply)

        expect(nested.thread_root).to eq(root)
      end
    end

    describe "circular parentage" do
      it "rejects a thought that is its own parent" do
        thought = create(:thought, content: "Self referencing thought")
        thought.parent_id = thought.id

        expect(thought).not_to be_valid
        expect(thought.errors[:parent_id]).to include("can't be itself")
      end

      it "rejects a cycle between two thoughts" do
        a = create(:thought, content: "Thought A")
        b = create(:thought, content: "Thought B", parent: a)

        a.parent = b

        expect(a).not_to be_valid
        expect(a.errors[:parent_id]).to include("can't create a circular thread")
      end

      it "allows a legitimate nested chain" do
        root = create(:thought, content: "Root thought")
        reply = create(:thought, content: "Reply thought", parent: root)
        nested = build(:thought, content: "Nested reply", parent: reply)

        expect(nested).to be_valid
      end
    end

    describe "dependent destroy" do
      it "destroys replies when the parent is destroyed" do
        parent = create(:thought, content: "Parent thought")
        reply = create(:thought, content: "Reply thought", parent: parent)
        create(:thought, content: "Nested reply", parent: reply)

        expect { parent.destroy }.to change(Thought, :count).by(-3)
      end
    end
  end
end
