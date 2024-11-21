# frozen_string_literal: true

module SelectOption
  extend ActiveSupport::Concern

  LEGAL_STATUS = %w[SARL EURL SA SAS Auto-entrepreneur].freeze
end
