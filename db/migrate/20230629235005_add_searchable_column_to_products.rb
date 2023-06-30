class AddSearchableColumnToProducts < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION f_unaccent(text)
        RETURNS text
        LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT AS
      $func$
      SELECT unaccent('unaccent', $1)  -- schema-qualify function and dictionary
      $func$;
      
      ALTER TABLE products
      ADD COLUMN searchable tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('portuguese', f_unaccent(coalesce("name"::text, ''))), 'A') ||
        setweight(to_tsvector('portuguese', f_unaccent(coalesce("brand"::text, ''))), 'A') ||
        setweight(to_tsvector('portuguese', f_unaccent(coalesce("store"::text, ''))), 'A') ||
        setweight(to_tsvector('portuguese', f_unaccent(coalesce("description"::text, ''))), 'B')
      ) STORED;
    SQL
  end

  def down
    remove_column :products, :searchable

    execute <<-SQL
      drop function f_unaccent(text);
    SQL
  end
end