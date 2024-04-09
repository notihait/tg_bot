require 'telegram/bot'
require 'pry'
require 'date'
require 'sqlite3'
require 'timeout'
require 'io/console'
require 'dotenv/load'

require_relative 'support/database'
require_relative 'support/api'
require_relative 'app/models'
require_relative 'app/views'
require_relative 'app/workers'

class TelegramBot
  TOKEN = '6757899794:AAHI-_XNtXMCGAndtkAwB3YTl0sQlSmYnos'
  def self.run
    should_exit = false
    Telegram::Bot::Client.run(TOKEN) do |bot|
      Workers::UserNotifyWorker.new(Database.init, bot).loop_perform
      loop do
        break if should_exit

        Timeout.timeout(10) do
          bot.listen do |message|
            user = Models::User.find_or_create(message.from.id)
            case message
            when Telegram::Bot::Types::Message
              Views::CityKeyboard.new(bot, message.from, user.city, user.time).render if message.text == '/start'
            when Telegram::Bot::Types::CallbackQuery
              attribute, value = message.data.split('_')
              p({ attribute.to_sym => value })
              user.update!(attribute.to_sym => value)
              Views::CityKeyboard.new(bot, message.from, user.city, user.time).render
            end
          end
        end
      rescue Timeout::Error
        begin
          Timeout.timeout(0.0001) do
            should_exit = $stdin.getch == 'q'
          end
        rescue Timeout::Error
          next
        end
      end
    end
  end
end

TelegramBot.run
