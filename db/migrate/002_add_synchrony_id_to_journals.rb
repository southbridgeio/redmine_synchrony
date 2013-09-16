class AddSynchronyIdToJournals < ActiveRecord::Migration

  def change
    add_column :journals, :synchrony_id, :integer
  end

end