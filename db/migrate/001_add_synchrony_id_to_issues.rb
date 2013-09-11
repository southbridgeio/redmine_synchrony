class AddSynchronyIdToIssues < ActiveRecord::Migration

  def change
    add_column :issues, :synchrony_id, :integer
  end

end