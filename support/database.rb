class Database
  def self.init
    db = SQLite3::Database.new(ENV['DATABASE'])
    db.execute <<-SQL
        create table users (
            chat_id int,
            city varchar(30),
            time varchar(5)
        );
    SQL
  ensure
    return db
  end
end
