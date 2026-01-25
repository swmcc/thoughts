require "rails_helper"

RSpec.describe "Public Timeline", type: :system do
  describe "viewing the timeline" do
    it "displays all thoughts" do
      thoughts = create_list(:thought, 3)

      visit root_path

      thoughts.each do |thought|
        expect(page).to have_content(thought.content)
      end
    end

    it "shows thoughts with tags" do
      thought = create(:thought, content: "Tagged thought", tags: [ "rails", "ruby" ])

      visit root_path

      expect(page).to have_content("Tagged thought")
      expect(page).to have_content("#rails")
      expect(page).to have_content("#ruby")
    end

    it "shows empty state when no thoughts exist" do
      visit root_path

      expect(page).to have_content("No thoughts yet")
    end
  end

  describe "filtering by tag" do
    it "filters thoughts when clicking a tag" do
      rails_thought = create(:thought, content: "Rails content", tags: [ "rails" ])
      ruby_thought = create(:thought, content: "Ruby content", tags: [ "ruby" ])

      visit root_path
      click_link "#rails"

      expect(page).to have_content("Rails content")
      expect(page).not_to have_content("Ruby content")
      expect(page).to have_content("Thoughts tagged #rails")
    end

    it "clears filter when clicking Clear filter" do
      create(:thought, content: "Rails content", tags: [ "rails" ])
      create(:thought, content: "Ruby content", tags: [ "ruby" ])

      visit root_path(tag: "rails")
      click_link "Clear filter"

      expect(page).to have_content("Rails content")
      expect(page).to have_content("Ruby content")
    end
  end

  describe "source icon display" do
    it "displays source icon with tooltip on timeline" do
      thought = create(:thought, content: "Web thought", source: "web")

      visit root_path

      within(".thought-card") do
        expect(page).to have_css("span[title='Written from web']")
        expect(page).to have_css("span[title='Written from web'] svg")
      end
    end

    it "displays source icon for cli source" do
      thought = create(:thought, content: "CLI thought", source: "cli")

      visit root_path

      within(".thought-card") do
        expect(page).to have_css("span[title='Written from CLI']")
        expect(page).to have_css("span[title='Written from CLI'] svg")
      end
    end

    it "displays source icon for iphone source" do
      thought = create(:thought, content: "iPhone thought", source: "iphone")

      visit root_path

      within(".thought-card") do
        expect(page).to have_css("span[title='Written from iPhone']")
        expect(page).to have_css("span[title='Written from iPhone'] svg")
      end
    end

    it "displays source icon on individual thought page" do
      thought = create(:thought, content: "Detail thought", source: "web")

      visit thought_path(thought)

      expect(page).to have_css("span[title='Written from web']")
      expect(page).to have_css("span[title='Written from web'] svg")
    end
  end

  describe "viewing individual thought" do
    it "shows full thought details" do
      thought = create(:thought, content: "Full thought content", tags: [ "test" ])

      visit root_path
      click_link "Full thought content"

      expect(page).to have_content("Full thought content")
      expect(page).to have_content("#test")
      expect(page).to have_link("Back to timeline")
    end

    it "increments view count" do
      thought = create(:thought, view_count: 5)

      visit thought_path(thought)

      expect(thought.reload.view_count).to eq(6)
    end
  end
end
