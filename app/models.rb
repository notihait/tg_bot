module Models
  DATABASE = Database.init
  class User
    attr_accessor :city, :time
    attr_reader   :chat_id

    def initialize(chat_id, city, time)
      @chat_id = chat_id
      @city = city
      @time = time
    end

    def update!(attributes)
      @city = attributes[:city] if attributes.keys.include? :city
      @time = attributes[:time] if attributes.keys.include? :time
      save!
    end

    def save!
      DATABASE.execute('UPDATE users SET city = ?, time = ? WHERE chat_id = ?', [city, time, chat_id])
    end

    def self.find_or_create(chat_id)
      existing_chat_id, city, time = DATABASE.execute('SELECT chat_id, city, time FROM users WHERE chat_id = ? LIMIT 1', [chat_id]
      ).first

      if [existing_chat_id, city, time].compact.empty?
        DATABASE.execute('INSERT INTO users (chat_id, city, time) VALUES (?, ?, ?)', [chat_id, nil, nil])
      end

      new(chat_id, city, time)
    end

    def self.count
      DATABASE.execute('SELECT COUNT(*) FROM users;').first.first
    end

    def self.should_be_notified_at(time)
      DATABASE.execute('SELECT chat_id, city, time FROM users WHERE time = ? AND city IS NOT NULL', [time]).map do |attrs|
        new(*attrs)
      end
    end
  end
end
