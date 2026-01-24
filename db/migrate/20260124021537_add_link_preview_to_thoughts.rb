class AddLinkPreviewToThoughts < ActiveRecord::Migration[8.1]
  def change
    add_column :thoughts, :link_url, :string
    add_column :thoughts, :link_title, :string
    add_column :thoughts, :link_description, :string
    add_column :thoughts, :link_image, :string
  end
end
