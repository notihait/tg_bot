module Workers
  class Base
    def initialize(db, bot)
      @bot = bot
      @db = db
      @threads = []
    end

    def loop_perform(delay: 60)
      @threads << Thread.new do
        loop do
          perform
          sleep delay
        rescue StandardError
          sleep delay
        end
      end
    end
  end

  class UserNotifyWorker < Base
    def perform
      users = Models::User.should_be_notified_at(DateTime.now.strftime('%H:%M'))
      max_steps = users.count * 3
      steps = 0
      loop do
        steps += 1
        break if steps > max_steps
        break if users.empty?

        user = users.shift

        weather_data = Api.current_weather(user.city)
        Views::WeatherReport.new(@bot, user.chat_id, weather_data, user.city).render
        sleep 0.1
      rescue StandardError => e
        reise e if steps == max_steps
        user.add(user)
      end
    end
  end
end
