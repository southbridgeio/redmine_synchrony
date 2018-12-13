class AddSynchronyIdToJournals < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]

  def change
    add_column :journals, :synchrony_id, :integer
  end

end