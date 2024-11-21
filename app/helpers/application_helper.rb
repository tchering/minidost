# frozen_string_literal: true

module ApplicationHelper
  def current_locale_flag
    case I18n.locale
    when :en
      'flag-united-kingdom'
    when :fr
      'flag-france'
    end
  end
end
