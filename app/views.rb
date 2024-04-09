module Views
  CITY_MAPPING = {
    'Київ' => 'Kyiv',
    'Донецьк' => 'Donetsk',
    'Харків' => 'Kharkiv',
    'Львів' => 'Lviv',
    'Луганськ' => 'Lugansk',
    'Луцьк' => 'Lutsk',
    'Вінниця' => 'Vinnitsa',
    'Одеса' => 'Odesa',
    'Дніпро' => 'Dnipro',
    'Житомир' => 'Zhytomyr',
    'Запоріжжя' => 'Zaporizhzhya',
    'Івано-Франківськ' => "Ivano-Frankivs\'ka Oblast\'",
    'Кропивницький' => 'Kirovohrad',
    'Миколаїв' => "Mykolayivs\'ka Oblast\'",
    'Полтава' => 'Poltava',
    'Рівне' => 'Rivne',
    'Суми' => 'Sumy',
    'Тернопіль' => 'Ternopil',
    'Ужгород' => 'Uzhgorod',
    'Херсон' => 'Kherson',
    'Хмельницький' => "Khmel\'nyts\'ka Oblast",
    'Черкаси' => 'Cherkasy',
    'Симферопіль' => 'Krym',
    'Чернігів' => 'Chernihiv',
    'Чернівці' => 'Chernivtsi'
  }.freeze

  class WeatherReport
    def initialize(bot, chat_id, weather_data, city)
      @bot = bot
      @chat_id = chat_id
      @weather_data = weather_data
      @city = city
    end

    def message_body
      "Погода зараз (#{@city})
       Температура: #{@weather_data[:temp]}°C
       Відчуваться як #{@weather_data[:feelslike]}°C
       Вологсть: #{@weather_data[:humidity]}%
       Втер: #{@weather_data[:wind]} м/с
       #{@weather_data[:wthr]}
      "
    end

    def render
      @bot.api.send_message(chat_id: @chat_id, text: message_body)
    end
  end

  class CityKeyboard
    TIMES = (0..23).map { |hour| "#{'%02d' % hour}:00" }

    def city_keys
      CITY_MAPPING.map do |key, value|
        active = value == @current_city ? '✅' : ''
        Telegram::Bot::Types::InlineKeyboardButton.new(text: key + active, callback_data: "city_#{value}")
      end.each_slice(2).to_a
    end

    def time_keys
      TIMES.map do |time|
        active = time == @current_time ? '✅' : ''
        Telegram::Bot::Types::InlineKeyboardButton.new(text: time + active, callback_data: "time_#{time}")
      end.each_slice(4).to_a
    end

    def keyboard
      Telegram::Bot::Types::InlineKeyboardMarkup.new(
        inline_keyboard: city_keys + time_keys,
        one_time_keyboard: false
      )
    end

    def render
      @bot.api.send_message(chat_id: @chat.id, text: 'Оберіть місто та час', reply_markup: keyboard)
    end

    def initialize(bot, chat, current_city, current_time)
      @bot = bot
      @current_city = current_city
      @current_time = current_time
      @chat = chat
    end
  end
end
