class AddSynchronizedAtToIssues < ActiveRecord::Migration

  def change
    add_column :issues, :synchronized_at, :timestamp
  end

end