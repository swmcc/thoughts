class AddLinkPreviewsToThoughts < ActiveRecord::Migration[8.1]
  def change
    add_column :thoughts, :link_previews, :jsonb, default: []

    # Migrate existing single link previews to the new array format
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE thoughts
          SET link_previews = jsonb_build_array(
            jsonb_build_object(
              'url', link_url,
              'title', link_title,
              'description', link_description,
              'image', link_image
            )
          )
          WHERE link_url IS NOT NULL
        SQL
      end
    end
  end
end
