# 日時のデフォルトフォーマットをl18nを前提としてフォーマットにする
# See: https://api.rubyonrails.org/classes/DateTime.html#method-i-to_formatted_s
# Date
Date::DATE_FORMATS[:default] = ->(date) { I18n.l(date) }
Date::DATE_FORMATS[:long] = ->(date) { I18n.l(date, format: :long) }
Date::DATE_FORMATS[:short] = ->(date) { I18n.l(date, format: :short) }
# Time
Time::DATE_FORMATS[:default] = ->(time) { I18n.l(time) }
Time::DATE_FORMATS[:long] = ->(time) { I18n.l(time, format: :long) }
Time::DATE_FORMATS[:short] = ->(time) { I18n.l(time, format: :short) }
