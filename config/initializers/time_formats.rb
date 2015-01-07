Date::DATE_FORMATS[:short_ordinal] = lambda { |date| date.strftime("%B #{date.day.ordinalize}") }
Time::DATE_FORMATS[:short_ordinal] = lambda { |date| date.strftime("%B #{date.day.ordinalize}") }