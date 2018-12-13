class AddSynchronizedAtToIssues < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]

  def change
    add_column :issues, :synchronized_at, :timestamp
  end

end